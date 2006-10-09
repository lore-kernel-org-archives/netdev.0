From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Marvell 88E8001 - WoL - GigaBitSwitch
Date: Mon, 9 Oct 2006 08:46:39 -0700
Message-ID: <20061009084639.3ee7f7e4@freekitty>
References: <002a01c6e796$873a8db0$0200a8c0@sokrates>
	<20061004102548.401e0add@freekitty>
	<000401c6eba6$afecd470$0200a8c0@sokrates>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47309 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932720AbWJIQsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2006 12:48:20 -0400
To: "TiVi" <tivi21de@yahoo.de>
In-Reply-To: <000401c6eba6$afecd470$0200a8c0@sokrates>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Oct 2006 15:27:32 +0200
"TiVi" <tivi21de@yahoo.de> wrote:

> Hello Stephen,
> 
> thanks for response. Sorry for lag in posting. I was ill.
> 
> Short description of my problem:
> 
> My machine has an onboard NIC (Marvell 88E8001).
> I am running Debian Sarge (Kernel 2.6.16).
> skge is loaded. I use ethtool to set WoL by MagicPacket.
> 
> Unfortunately, the machine is not waking up if it is
> connected to my gigabit switch. BTW, I could do
> some testing with three different gigabit switches.
> 
> Using direct, old 10MBit Hub or 10/100 MBit Switch
> connection, the machine always wakes up.
> 
> If I shutdown the machine using WinXP, the machine is
> waking up although it is connected to the gigabit switch.
> 
> Could not test sk98lin driver. Not easy to me.
> If needed I will try.
> 
> Regards,
> 
> Per

WOL is not working yet with skge. I would try sk98lin to see if that works.
Tell me if it does, that will help in fixing skge.

-- 
Stephen Hemminger <shemminger@osdl.org>
