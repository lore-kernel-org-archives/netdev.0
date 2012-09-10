From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCH v2] lxt PHY: Support for the buggy LXT973 rev A2
Date: Mon, 10 Sep 2012 20:17:47 +0200
Message-ID: <20120910181747.GA5960@lutz.bln.innominate.local>
References: <201209101545.q8AFjn7u021483@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201209101545.q8AFjn7u021483@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2012 at 05:45:49PM +0200, Christophe Leroy wrote:
> This patch adds proper handling of the buggy revision A2 of LXT973 ph=
y, adding
> precautions linked to ERRATA Item 4:
>=20
> Item 4: MDIO Interface and Repeated Polling
> Problem: Repeated polling of odd-numbered registers via the MDIO inte=
rface
> 	randomly returns the contents of the previous even register.
> Implication: Managed applications may not obtain the correct register=
 contents
> 	when a particular register is monitored for device status.
> Workaround: None.
> Status: This erratum has been previously fixed (in rev A3)

Hmm. Were did you get the hardware from? We have been using LXT973 in
our products and the A2 was replaced by A3 in 2003.

Best regards,
	Lutz
--=20
Dr.-Ing. Lutz J=E4nicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.921028-200
fax: +49.30.921028-020
Rudower Chaussee 13
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Dirk Seewald
Chairman of the Supervisory Board: Christoph Leifer
