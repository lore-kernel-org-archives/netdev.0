From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [RFC net-next 3/3] mpls: new ipmpls device for encapsulating
 IP packets as mpls
Date: Tue, 02 Jun 2015 09:15:04 -0700
Message-ID: <556DD688.2020308@cumulusnetworks.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <1433177175-16775-4-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:36092 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbbFBQPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 12:15:08 -0400
Received: by qkx62 with SMTP id 62so103447185qkx.3
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 09:15:07 -0700 (PDT)
In-Reply-To: <1433177175-16775-4-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/15, 9:46 AM, Robert Shearman wrote:
> Allow creating an mpls device for the purposes of encapsulating IP
> packets with:
>
>    ip link add type ipmpls
>
> This device defines its per-nexthop encapsulation data as a stack of
> labels, in the same format as for RTA_NEWST. It uses the encap data
> which will have been stored in the IP route to encapsulate the packet
> with that stack of labels, with the last label corresponding to a
> local label that defines how the packet will be sent out. The device
> sends packets over loopback to the local MPLS forwarding logic which
> performs all of the work.
>
>
Maybe a silly question, but when you loop the packet back, what does the 
local MPLS forwarding logic
lookup with ? It probably assumes there is a mpls route with that label 
and nexthop.
Will this need any internal labels (thinking same label stack different 
tunnel device etc) ?
