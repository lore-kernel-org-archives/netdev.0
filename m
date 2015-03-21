From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Fri, 20 Mar 2015 17:26:30 -0700
Message-ID: <CAE4R7bDpsnqCjayXpsbhn-tYuuiiFuAgsZPufHCUh+KYSr+9mg@mail.gmail.com>
References: <1426870714-3225-1-git-send-email-roopa@cumulusnetworks.com>
	<550C54BC.4040509@intel.com>
	<CAE4R7bCC=VZerEfVRfn=NmQvE9bwQ-KGo7v77ghHOLAR5p5hwg@mail.gmail.com>
	<550C99DD.3090007@cumulusnetworks.com>
	<CAE4R7bBd8TeNCiXdOL9en-FfuTqqn==UYvAxHHD8BYHuFCiWBw@mail.gmail.com>
	<550CAD97.3000404@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:34205 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbbCUA0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 20:26:31 -0400
Received: by qcay5 with SMTP id y5so16775937qca.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 17:26:30 -0700 (PDT)
In-Reply-To: <550CAD97.3000404@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 4:30 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 3/20/15, 3:37 PM, Scott Feldman wrote:
[cut]
>>
>> I went back and read the thread just to remind me what the pros/cons
>> where.  I think the mixed case isn't a concern since this
>> BR_FLOOD_BCAST check is made on egress to the bridge port.  So only
>> clear BR_FLOOD_BCAST on hw switch ports (if hw did the flood already
>> amongst its ports), and leave it set for non-hw-ports.   It seems the
>> patch should mostly be a clone of how BR_FLOOD is handled.  Is there
>> more to it?
>
> That may work.  But, we have recently moved igmp handling to software in
> kernel and i was trying to make this work for that case. I am going to try what you
> suggest  by finding a work around for the igmp case.

Wait, you lost me on the IGMP comment...that wasn't in your commit
msg.  Do you mean IGMP snooping?  What are you trying to get to work?

It's hard to understand the pieces you're considering without example
implementations.  Can you use rocker or DSA to show example?
