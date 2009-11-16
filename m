From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] net/can: add driver for mscan family & mpc52xx_mscan
Date: Mon, 16 Nov 2009 14:08:39 +0100
Message-ID: <4B014ED7.1050500@grandegger.com>
References: <1258128892-28800-1-git-send-email-w.sang@pengutronix.de> <4B0110D5.6010405@grandegger.com> <20091116102414.GB30609@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	socketcan-core@lists.berlios.de, linuxppc-dev@ozlabs.org,
	David Miller <davem@davemloft.net>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:60030 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbZKPNJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:09:12 -0500
In-Reply-To: <20091116102414.GB30609@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfram,

Wolfram Sang wrote:
> Hi Wolfgang,
> 
> On Mon, Nov 16, 2009 at 09:44:05AM +0100, Wolfgang Grandegger wrote:
>> Hi Wolfram,
>>
>> thanks for pushing this driver to mainline. I think you should also add
>> a CC to the Devicetree-discuss ML.
> 
> thank you very much for your review! I agree with nearly all of your points and will
> send an update today. The only thing I have doubts about is removing those lines:

Thanks, quite a bit of work.

>> +MODULE_AUTHOR("Andrey Volkov <avolkov@varma-el.com>");
>> +MODULE_LICENSE("GPL v2");
>> +MODULE_DESCRIPTION("CAN port driver for a MSCAN based chips");
> 
> I looked around in the kernel sources and found that they are often present in
> generic modules, even if they can't be used without a wrapper (examples are all
> files in drivers/i2c/algos or drivers/net/wireless/iwlwifi/iwl-core.c). As I'm
> also a bit anxious to fiddle with other people's authorship, I'd prefer to keep
> them.

They do not harm, fine for me.

> Finally, I'll also try to test suspend/resume, but I have to find out if it is
> supported on that board in general.

Maybe somebody else already uses suspend/resume on a MPC5200 board with
Socket-CAN and could provide some feedback.

Wolfgang.
