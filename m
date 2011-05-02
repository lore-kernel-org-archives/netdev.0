From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Mon, 02 May 2011 12:46:22 -0700 (PDT)
Message-ID: <20110502.124622.226785624.davem@davemloft.net>
References: <1304264799.2833.82.camel@localhost>
	<1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	pmcenery@gmail.com, david.hill@ubisoft.com,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: agimenez@sysvalve.es
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: L. Alberto Gim=E9nez <agimenez@sysvalve.es>
Date: Mon,  2 May 2011 21:35:12 +0200

> Since commit ea812ca1b06113597adcd8e70c0f84a413d97544 (x86: Align skb=
 w/ start
> of cacheline on newer core 2/Xeon Arch), NET_IP_ALIGN changed from 2 =
to 0, and
> the constant is used to reserve more room for the socket buffer.
>=20
> Some people have reported that tethering stopped working and David Hi=
ll
> submited a patch that redefined NET_IP_ALIGN. Pointed by Ben Hutching=
s, the
> patch has been reworked to use a private constant.
>=20
> I have no more an iPhone device to test it, so it is only compile-tes=
ted.
>=20
> Signed-off-by: L. Alberto Gim=E9nez <agimenez@sysvalve.es>

Why did this break things?

I'm not applying a fix when nobody can explain the reason why:

1) Things broke in the first place
2) Forcing reservation of 2 bytes fixes things

Where is the built in assumption about "2" and why does it exist?  Why
can't we fix this code not to have such assumptions in the first
place?
