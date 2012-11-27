From: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Subject: Re: VPN traffic leaks in IPv6/IPv4 dual-stack networks/hosts
Date: Tue, 27 Nov 2012 17:22:47 +0100
Message-ID: <11198745.Qe2H0cIWZB@alaris>
References: <50B4D43A.7030208@gont.com.ar> <1354032252.14302.37.camel@edumazet-glaptop> <50B4E52C.8090507@gont.com.ar>
Reply-To: Michal =?utf-8?B?S3ViZcSNZWs=?= <mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56011 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755913Ab2K0QWt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 11:22:49 -0500
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 8803AA3A49
	for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 17:22:48 +0100 (CET)
In-Reply-To: <50B4E52C.8090507@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 of November 2012 13:07EN, Fernando Gont wrote:
> > accept_ra on linux is set to 1, meaning that as soon as forwarding
> > is
> > enabled, RA are ignored.
>=20
> I don't follow. Why would RAs be ignored if accept_ra is set to 1??

Value of 1 means "Accept Router Advertisements if forwarding is=20
disabled.", see Documentation/networking/ip-sysct.txt

                                                        Michal Kube=E8e=
k
