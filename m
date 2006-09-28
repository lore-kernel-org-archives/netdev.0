From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 13:39:18 -0700
Message-ID: <1159475958.3741.13.camel@rh4>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
 <1159474625.3741.6.camel@rh4>
 <Pine.LNX.4.64.0609281632200.28620@d.namei>
 <451C3224.8030903@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "James Morris" <jmorris@namei.org>,
	"Stephen Hemminger" <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1807 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S1750812AbWI1Umr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 16:42:47 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <451C3224.8030903@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 16:35 -0400, Jeff Garzik wrote:
> James Morris wrote:
> > On Thu, 28 Sep 2006, Michael Chan wrote:
> > 
> >> I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
> >> Dumping 64K worth of registers and blinking the LEDs should be
> >> restricted.
> > 
> > Out of curiosity -- why?
> 
> In the past, dumping certain tg3 registers has led to lock-ups, for one.
> 
> Also, blindly dumping registers can negatively affect driver operation, 
> for the case where reading registers has side effects, such as PHY 
> register bit shifting, or read-and-clear registers.
> 

That's right.  For the LED blinking part, you don't want normal users to
override the normal functions of LEDs which are to indicate link, speed,
traffic, etc.

