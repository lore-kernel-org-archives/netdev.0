From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: PHY down?
Date: Fri, 5 Aug 2011 06:13:09 +0200
Message-ID: <20110805041309.GB15141@zapo>
References: <OF6D5A2ABF.61D9AA63-ONC12578E0.00335EE4-C12578E0.0033AE22@transmode.se>
 <1312282868.2591.68.camel@deadeye>
 <OFEC77B7FA.1BCB17E8-ONC12578E0.0043754B-C12578E0.00441F36@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37206 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab1HEENN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2011 00:13:13 -0400
Received: by fxh19 with SMTP id 19so2405261fxh.19
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2011 21:13:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <OFEC77B7FA.1BCB17E8-ONC12578E0.0043754B-C12578E0.00441F36@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 02, 2011 at 02:24:04PM +0200, Joakim Tjernlund wrote:
> Ben Hutchings <bhutchings@solarflare.com> wrote on 2011/08/02 13:01:08:
> >
> > On Tue, 2011-08-02 at 11:24 +0200, Joakim Tjernlund wrote:
> > > I must be missing something obvious but I cannot find how
> > > to bring eth0's PHY down (link down) from user space.
> > > Tried various settings with ethtool and ifconfig eth0 down but it didn't help.
> >
> > If you configure an interface down, and if the interface is not used for
> > remote management, then some drivers will turn the PHY off.  But there
> > is no general way to control this explicitly.
> 
> OK, when to stop the PHY doesn't seem standardized. Seem logical to me
> to also turn off the PHY when interface is configured down. Perhaps this could
> be agreed upon?
> What does remote management mean? How do I identify if the I/F is used for remote management?
> 
>  Jocke

I'd rather see an explicit way of turning off the PHY. Downing the interface might be
useful without killing the PHY. I've seen PoE switches that kill you when you bring
the link down or reset the PHY after once beeing up, Down/up of interface might become
impossible in some environments if we would standardize on PHY off for interface down.

Maybe an explicit ethtool option?

Cheers
