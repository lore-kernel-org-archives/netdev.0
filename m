From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [patch v2] phonet: some signedness bugs
Date: Thu, 13 Jan 2011 14:32:57 +0200
Message-ID: <201101131432.58059.remi.denis-courmont@nokia.com>
References: <20110107203755.GB1959@bicker> <20110110140658.GB2721@bicker> <20110110.160620.133889003.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com, dan.j.rosenberg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.26]:60841 "EHLO mgw-da02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756629Ab1AMMcp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 07:32:45 -0500
In-Reply-To: <20110110.160620.133889003.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 11 January 2011 02:06:20 ext David Miller, you wrote:
> From: Dan Carpenter <error27@gmail.com>
> Date: Mon, 10 Jan 2011 17:06:58 +0300
>=20
> > Dan Rosenberg pointed out that there were some signed comparison bu=
gs
> > in the phonet protocol.
> >=20
> > http://marc.info/?l=3Dfull-disclosure&m=3D129424528425330&w=3D2
> >=20
> > The problem is that we check for array overflows but "protocol" is
> > signed and we don't check for array underflows.  If you have alread=
y
> > have CAP_SYS_ADMIN then you could use the bugs to get root, or some=
one
> > could cause an oops by mistake.
> >=20
> > Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> Applied.

Shouldn't this be sent to stable trees?

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
