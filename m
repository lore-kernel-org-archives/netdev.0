From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel panic when using bridge
Date: Tue, 12 Apr 2011 18:35:52 +0200
Message-ID: <1302626152.3233.66.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam> <4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302608951.3233.33.camel@edumazet-laptop>
	 <1302613353.30934.22.camel@polaris.local>
	 <1302614145.3233.47.camel@edumazet-laptop>
	 <1302617968.30934.34.camel@polaris.local>
	 <1302619749.3233.56.camel@edumazet-laptop>
	 <1302621233.30934.44.camel@polaris.local>
	 <1302624851.3233.63.camel@edumazet-laptop>
	 <20110412092039.69f420f6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan =?ISO-8859-1?Q?L=FCbbe?= <jluebbe@debian.org>,
	Scot Doyle <lkml@scotdoyle.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org, Bandan Das <bandan.das@stratus.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58890 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758132Ab1DLQf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 12:35:57 -0400
Received: by wya21 with SMTP id 21so5850153wya.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 09:35:55 -0700 (PDT)
In-Reply-To: <20110412092039.69f420f6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 09:20 -0700, Stephen Hemminger a =C3=A9cr=
it :

> I think the confusion is that IPCB(skb) is not the IP header but
> scratch space used during IP header processing. Before the sanitize
> patch the CB was cleared.
>=20
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Should we clear it also in br_nf_dev_queue_xmit(), since we did this
prior to commit 462fb2af9788a8 ?

Thanks !


