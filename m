From: =?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Mon, 2 May 2011 23:12:45 +0200
Message-ID: <20110502211245.GA18334@bart.evergreen.loc>
References: <1304264799.2833.82.camel@localhost>
 <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
 <20110502.124622.226785624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	pmcenery@gmail.com, david.hill@ubisoft.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n023010.sys.capside.net ([81.25.117.138]:56440 "EHLO
	n023010.sys.capside.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433Ab1EBVTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2011 17:19:32 -0400
Content-Disposition: inline
In-Reply-To: <20110502.124622.226785624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 02, 2011 at 12:46:22PM -0700, David Miller wrote:
>=20
> Why did this break things?

Hi, I don't know. As upstream is unresponsive and is applying patches t=
o his
private repo without submitting them to the list (which I can understan=
d), I
decided to submit the particular fix so mainline users can get tetherin=
g working
again.

I received a forwarded email with the patch (I think that's because I s=
ubmitted
the driver to mainline) asking for the mainline driver status and if it=
 was
being maintained.

>=20
> I'm not applying a fix when nobody can explain the reason why:
>=20
> 1) Things broke in the first place
> 2) Forcing reservation of 2 bytes fixes things

Honestly, I can't answer either of those ones. I just submitted a patch=
 that
*seemed* to fix the problem (I don't own an iPhone device since long ti=
me ago),
after explictly requesting upstream to submit by himself, and getting a
negative.


> Where is the built in assumption about "2" and why does it exist?  Wh=
y
> can't we fix this code not to have such assumptions in the first
> place?

Ditto.

At this point, I think that David, Diego or Daniel should step in if th=
ey want
to keep on with this discussion. I won't have problems if you want to t=
ake this
off-list.

Best regards,

--=20
L. Alberto Gim=E9nez
JabberID agimenez@jabber.sysvalve.es
GnuPG key ID 0x3BAABDE1
