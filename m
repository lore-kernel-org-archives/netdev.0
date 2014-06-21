From: Fabian Frederick <fabf@skynet.be>
Subject: Re: [PATCH 1/1] net/dsa/dsa.c: remove null test before kfree
Date: Sat, 21 Jun 2014 11:36:53 +0200
Message-ID: <20140621113653.6b2dd148b35a6ecfb7c08cce@skynet.be>
References: <1403296607-6065-1-git-send-email-fabf@skynet.be>
	<b991e868-c253-4b1a-8c95-56106c36d512@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay001.isp.belgacom.be ([195.238.6.51]:11345 "EHLO
	mailrelay001.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754748AbaFUJgm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Jun 2014 05:36:42 -0400
In-Reply-To: <b991e868-c253-4b1a-8c95-56106c36d512@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Jun 2014 10:37:24 +0200
Bj=F8rn Mork <bjorn@mork.no> wrote:

>=20
>=20
> On 20 June 2014 22:36:47 CEST, Fabian Frederick <fabf@skynet.be> wrot=
e:
> >Fix checkpatch warning:
> >WARNING: kfree(NULL) is safe this check is probably not required
>=20
> "probably not" implies that there are cases where the check *is* requ=
ired.  That means that your commit message should explain why this part=
icular check is redundant.
>=20
> I haven't analyzed your changes here, so they could be fine for all I=
 know. My point is that such analysis is your job when submitting clean=
ups like this one.
>=20
>=20
>=20
AFAIK, any

if(foo)
	kfree(foo)
=09
can be updated to kfree(foo) but

if (foo){
	kfree(foo)
	do something else
}

has to be evaluated ; reason for the "probably" in warning message.
If I'm wrong maybe we could be more verbose in checkpatch :)
(I added Joe Perches in Cc list ; maybe he can help here)

=46abian

> Bj=F8rn
