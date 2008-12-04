From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: ixp4xx_hss. Little bug in hss_init_one
Date: Thu, 04 Dec 2008 21:32:07 +0100
Message-ID: <m38wqvznp4.fsf@maximus.localdomain>
References: <b0438a630811260913t638343a4i5576292b367c5dc2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:49340 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754669AbYLDUcJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:32:09 -0500
In-Reply-To: <b0438a630811260913t638343a4i5576292b367c5dc2@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Wed\, 26 Nov
 2008 18\:13\:06 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> I have found that platform_set_drvdata is not correctly called if we
> have an error in requesting npe. Am I right?

Definitely. Though I will just move platform_set_drvdata() past
npe_request() (and register_hdlc_device()).

Thanks for spotting this bug.
--=20
Krzysztof Halasa
