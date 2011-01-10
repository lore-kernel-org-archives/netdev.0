From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [patch v2] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 16:12:03 +0200
Message-ID: <201101101612.04296.remi.denis-courmont@nokia.com>
References: <20110107203755.GB1959@bicker> <201101100958.32549.remi.denis-courmont@nokia.com> <20110110140658.GB2721@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	dan.j.rosenberg@gmail.com
To: ext Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.26]:61298 "EHLO mgw-da02.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab1AJOLy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:11:54 -0500
In-Reply-To: <20110110140658.GB2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 January 2011 16:06:58 ext Dan Carpenter, you wrote:
> Dan Rosenberg pointed out that there were some signed comparison bugs
> in the phonet protocol.
>=20
> http://marc.info/?l=3Dfull-disclosure&m=3D129424528425330&w=3D2
>=20
> The problem is that we check for array overflows but "protocol" is
> signed and we don't check for array underflows.  If you have already
> have CAP_SYS_ADMIN then you could use the bugs to get root, or someon=
e
> could cause an oops by mistake.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>


--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
