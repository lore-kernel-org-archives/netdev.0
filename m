From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 3/3] mpls: support for ip tunnels
Date: Sat, 20 Jun 2015 07:41:04 -0700
Message-ID: <55857B80.7090103@cumulusnetworks.com>
References: <1434689355-4088-4-git-send-email-roopa@cumulusnetworks.com> <55843E15.2040301@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, tgraf@suug.ch, davem@davemloft.net,
	netdev@vger.kernel.org,
	Vivek Venkatraman <vivek@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35873 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547AbbFTOlF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 10:41:05 -0400
Received: by paceq1 with SMTP id eq1so79299350pac.3
        for <netdev@vger.kernel.org>; Sat, 20 Jun 2015 07:41:05 -0700 (PDT)
In-Reply-To: <55843E15.2040301@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 9:06 AM, Robert Shearman wrote:
>
> Since the entire label stack and the output device is encoded in the 
> route, this means that you won't get prefix-independent convergence 
> with this implementation for an IGP route change. I.e. if you've got 
> 10 million VPN routes via an IGP route for the BGP nexthop, and the 
> IGP route for the BGP nexthop changes (e.g. because a link has gone 
> down somewhere in the network) then you'll have to update all 10 
> million IP routes to change the output device, gateway and IGP label.
>
> That's going to represent a scaling obstacle for one of the primary 
> MPLS use cases.

I cant say I understand PIC very well, but, assuming PIC is not just an 
mpls thing, PIC does require an alternate nexthop infrastructure in the 
kernel (FIB).
And if that were present, It would help the mpls case too. I am not sure 
how you would solve PIC just for the mpls case or if having a netdevice 
makes it any easier.

Thanks,
Roopa
