From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH 09/10] net: Use VRF device index for socket lookups
Date: Wed, 05 Aug 2015 13:39:50 -0600
Message-ID: <55C26686.3010702@cumulusnetworks.com>
References: <1438794894-70217-1-git-send-email-dsa@cumulusnetworks.com>	<1438794894-70217-10-git-send-email-dsa@cumulusnetworks.com> <CALx6S35mAcKe5caMz-jiq9oy2M0e2c-kfKeCNb=f5A4j_Ct1=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	gospo@cumulusnetworks.com, jtoppins@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, svaidya@brocade.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35746 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbbHETjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 15:39:53 -0400
Received: by iodd187 with SMTP id d187so59901848iod.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 12:39:52 -0700 (PDT)
In-Reply-To: <CALx6S35mAcKe5caMz-jiq9oy2M0e2c-kfKeCNb=f5A4j_Ct1=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom:

On 8/5/15 12:32 PM, Tom Herbert wrote:
> On Wed, Aug 5, 2015 at 10:14 AM, David Ahern<dsa@cumulusnetworks.com>  wrote:
>> >The intent of the VRF device is to leverage the existing SO_BINDTODEVICE
>> >as a means of creating L3 domains. Since sockets are expected to be bound
>> >to the VRF device the index of the master device needs to be used for
>> >socket lookups.
>> >
> This patch set seems awfully invasive at the socket layer. Isn't there
> anyway this functionality be contained in the routing layer and
> sockets use existing API?

This patch is a leftover from earlier versions. It is no longer needed. 
Will drop for v5.

David
