From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 15:41:35 -0700
Message-ID: <20060928154135.2110633f@freekitty>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
	<451C2F52.6040003@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9701 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161348AbWI1WnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 18:43:16 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451C2F52.6040003@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 16:23:46 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > There is no reason to not allow non-admin users to query network
> > statistics and settings.
> 
> NAK.
> 
> Some functions in the past didn't like getting hit rapidly in succession.
> 
> I would agree to this, but only after an exhaustive audit of each driver 
> and each sub-ioctl.  Right now, I only have confidence in GDRVINFO 
> probably being safe -- but still that requires an audit, since in rare 
> cases the driver may be poking firmware and eeprom areas.
> 
> Finally, I fixed a buffer overflow in ethtool version 5, so an audit to 
> make sure overflows cannot affect the kernel is basically _required_.
> 
> 	Jeff

The first step should be conservative, so why not allow GDRVINFO, and the
various offload setting GTSO, GxSUM, ...

Agreed, that PHY stuff, register area, WOL, are bad. The statistics stuff
also might be a problem for some chips.

-- 
Stephen Hemminger <shemminger@osdl.org>
