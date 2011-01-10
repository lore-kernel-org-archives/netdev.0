From: Dan Carpenter <error27@gmail.com>
Subject: Re: [patch] phonet: some signedness bugs
Date: Mon, 10 Jan 2011 17:01:41 +0300
Message-ID: <20110110140141.GA2721@bicker>
References: <20110107203755.GB1959@bicker>
 <201101100958.32549.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, dan.j.rosenberg@gmail.com
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:42750 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426Ab1AJOCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:02:07 -0500
Content-Disposition: inline
In-Reply-To: <201101100958.32549.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 10, 2011 at 09:58:32AM +0200, R=E9mi Denis-Courmont wrote:
> On Friday 07 January 2011 22:37:55 ext Dan Carpenter, you wrote:
> > Dan Rosenberg pointed out that there were some signed comparison bu=
gs
> > in the phonet protocol.
>=20
> There are two ways to solve this: change *only* the proto_get functio=
n to use=20
> an unsigned parameter, or cast the protocol to unsigned in the compar=
ison.
>=20
> As David pointed out, your patch breaks the socket() callback prototy=
pe.
>=20

Yes.  I really appologize for that.  I'll send version 2 with that crea=
te()
change dropped.  It's not needed.

I would like to keep the change to phonet_proto_register() because the
check in there isn't right and it's similar to phonet_proto_get().   We
may as well keep phonet_proto_unregister() as well so it's symmetric.
Let me know if you disagree and I'll redo it.

regards,
dan carpenter
