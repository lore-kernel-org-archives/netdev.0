From: Steve Sakoman <sakoman@gmail.com>
Subject: Re: Remaining bits for basic support of LDP
Date: Mon, 2 Feb 2009 14:16:54 -0800
Message-ID: <5e088bd90902021416p3f0a29e8r4e4c4edb2adb1409@mail.gmail.com>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk>
	 <20090202.134530.63616213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:16505 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbZBBWQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 17:16:56 -0500
In-Reply-To: <20090202.134530.63616213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2009 at 1:45 PM, David Miller <davem@davemloft.net> wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Mon, 2 Feb 2009 21:39:53 +0000
>
>> The patch to fix these issues would seem to be relatively small (12
>> lines in the smc911x and one line change in board-ldp.c) - is it
>> something we want done for -rc4 or do we scrap the ethernet support
>> on the LDP until the SMSC driver has been merged ?
>>
>> Obviously, having working ethernet would be helpful, and since it was
>> half heartedly merged when the initial OMAP3 stuff went upstream we
>> should do something with it one way or another.
>
> Well, the SMSC driver is there already in the tree.
>
> The only thing not currently being scheduled to hit
> 2.6.29-rcX are the recent changes to support platform
> specified interrupt flags and all of that stuff.
>
> If you want, we can look into pushing that work into
> 2.6.29-rcX

That would be great!  The patch I recently submitted for Overo's SMSC
support really does need the platform specified interrupt flag patch
to function properly.  So accelerating those patches into 2.6.29-rcX
gets my vote :-)

Steve
