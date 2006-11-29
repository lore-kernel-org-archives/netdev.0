From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: [Madwifi-devel] ar5k and Atheros AR5005G
Date: Wed, 29 Nov 2006 15:55:49 +0200
Message-ID: <40f31dec0611290555t42d28247x7f163527fac438c1@mail.gmail.com>
References: <1164746352.31456.22.camel@systems03.lan.brontes3d.com>
	 <200611282145.08423.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Daniel Drake" <ddrake@brontes3d.com>, netdev@vger.kernel.org,
	madwifi-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:16377 "EHLO
	wx-out-0506.google.com") by vger.kernel.org with ESMTP
	id S967173AbWK2Nzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 08:55:50 -0500
Received: by wx-out-0506.google.com with SMTP id h27so2330876wxd
        for <netdev@vger.kernel.org>; Wed, 29 Nov 2006 05:55:50 -0800 (PST)
To: "Michael Buesch" <mb@bu3sch.de>
In-Reply-To: <200611282145.08423.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I 've already ported ar5k to linux and it works with madwifi versions
before the bsd-head merge, you can see more infos here ->
http://madwifi.org/wiki/OpenHAL

If i can help in any way feel free to mail ;-)

Nick

2006/11/28, Michael Buesch <mb@bu3sch.de>:
> On Tuesday 28 November 2006 21:39, Daniel Drake wrote:
> > Hi,
> >
> > I'm interested in porting the ar5k driver to Linux after the recent SFLC
> > conclusions on the legal status. However, the hardware I have here
> > appears to be unsupported by ar5k:
> >
> > 01:04.0 0200: 168c:001a (rev 01)
> >         Subsystem: 168c:2052
> >
> > 01:04.0 Ethernet controller: Atheros Communications, Inc. AR5005G
> > 802.11abg NIC (rev 01)
> >         Subsystem: Atheros Communications, Inc. Unknown device 2052
> >         Flags: bus master, medium devsel, latency 168, IRQ 66
> >         Memory at c0100000 (32-bit, non-prefetchable) [size=64K]
> >         Capabilities: [44] Power Management version 2
> >
> > It is a mini-PCI card.
> >
> > Does anyone know how much work would be needed for the ar5k codebase to
> > support this hardware?
>
> I started to port this at
> http://bu3sch.de/ath/atheros.git/
>
> I dunno how hard it is to add hw support.
>
> --
> Greetings Michael.
>
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> Madwifi-devel mailing list
> Madwifi-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/madwifi-devel
>
