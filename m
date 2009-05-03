From: Florian Fainelli <florian@openwrt.org>
Subject: Re: tulip_rxtx_stop() on Cobalt Qube2
Date: Sun, 3 May 2009 21:45:43 +0200
Message-ID: <200905032145.44294.florian@openwrt.org>
References: <200905011238.59345.florian@openwrt.org> <20090503113209.GC6617@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kyle@mcmartin.ca
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f224.google.com ([209.85.219.224]:37262 "EHLO
	mail-ew0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbZECTps convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2009 15:45:48 -0400
Received: by ewy24 with SMTP id 24so3437968ewy.37
        for <netdev@vger.kernel.org>; Sun, 03 May 2009 12:45:47 -0700 (PDT)
In-Reply-To: <20090503113209.GC6617@lackof.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

Le Sunday 03 May 2009 13:32:09 Grant Grundler, vous avez =E9crit=A0:
> On Fri, May 01, 2009 at 12:38:57PM +0200, Florian Fainelli wrote:

> I added the additional output. I'll need to grab the manuals and
> look up the bits.

That would be great, thanks.

>
> > eth0: Setting full-duplex based on MII#1 link partner capability of=
 45e1.
> >
> > The interface is still fully functional, shall we increase the time=
ount
> > in tulip_stop_rxtx() to prevent this message from appearing ?
>
> I expect the timeout (1.3ms) is long enough to cover "normal" cases.
> If something is taking longer than "normal", I'd like to know.
>
> If increasing it to 1.5 or 2ms makes this go away, I don't
> think I'll object.

Neither 1.5 nor 2 ms prevent this message from showing up. I have not c=
hecked=20
CoLo but maybe the bootloader has already configured the Ethernet inter=
faces=20
and therefore this check fails.
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
