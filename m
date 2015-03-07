From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] team: add support to get speed via ethtool
Date: Sat, 7 Mar 2015 07:47:27 -0500
Message-ID: <20150307124727.GG502@gospo.home.greyhouse.net>
References: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
 <20150306.002410.1359006818497057668.davem@davemloft.net>
 <20150307031013.GC502@gospo.home.greyhouse.net>
 <20150307.011443.2241226578473467570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sridhar.samudrala@intel.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34201 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbbCGMrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Mar 2015 07:47:32 -0500
Received: by qgdz60 with SMTP id z60so18802694qgd.1
        for <netdev@vger.kernel.org>; Sat, 07 Mar 2015 04:47:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150307.011443.2241226578473467570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 07, 2015 at 01:14:43AM -0500, David Miller wrote:
> From: Andy Gospodarek <gospo@cumulusnetworks.com>
> Date: Fri, 6 Mar 2015 22:10:13 -0500
> 
> > You have made it clear that despite the value others see in it, you are
> > opposed to setting the speed and duplex on things like tuntap and I
> > agree with you on this.  Doing that does nothing but continue to enable
> > offload hardware to live in userspace and that is not the proper
> > direction the kernel should take.
> 
> This is a scarecrow.
> 
> HW offloading has nothing at all to do with reporting complete
> bullshit link speed and duplex values on team/bonding devices.

I guess I read too much into the comments in this thread and merged them
with the ones on the changing/setting of tuntap speeds.  I'll circle
back with Stephen and Zhu to see if the want to resubmit something that
satisfies everyone's needs.
