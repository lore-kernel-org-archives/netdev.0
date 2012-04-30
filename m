From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFT] sky2: fix status length check on older chips
Date: Mon, 30 Apr 2012 09:19:52 -0700
Message-ID: <20120430091952.402567ad@nehalam.linuxnetplumber.net>
References: <4F9AFE4E.8010108@linuxsystems.it>
	<20120427134127.6d536a96@nehalam.linuxnetplumber.net>
	<20120427135514.48b03ce8@nehalam.linuxnetplumber.net>
	<4F9B2641.9070209@linuxsystems.it>
	<20120427194635.0b65b0ee@nehalam.linuxnetplumber.net>
	<4F9BC59D.80304@linuxsystems.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?B?TmljY29s8g==?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51269 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755126Ab2D3QUB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 12:20:01 -0400
In-Reply-To: <4F9BC59D.80304@linuxsystems.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Apr 2012 12:25:33 +0200
Niccol=F2 Belli <darkbasic@linuxsystems.it> wrote:

> Il 28/04/2012 04:46, Stephen Hemminger ha scritto:
> > Are you using VLAN's? the whole problem report only applies if usin=
g VLAN
> > on old hardware.
>=20
> No, I don't use VLANs. There are VLANs in my network but I simply=20
> connect to the default one from my laptop.

Still your laptop will receive vlan frames (even just broadcasts).
