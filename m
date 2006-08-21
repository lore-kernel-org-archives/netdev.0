From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [2.6.19 PATCH 1/7] ehea: interface to network stack
Date: Mon, 21 Aug 2006 15:18:31 +0200
Message-ID: <20060821131831.GA31094@wohnheim.fh-wedel.de>
References: <200608181329.02042.ossthema@de.ibm.com> <20060818144429.GF5201@martell.zuzino.mipt.ru> <200608211423.54250.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:24518 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S1751409AbWHUNSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 09:18:36 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608211423.54250.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 August 2006 14:23:53 +0200, Jan-Bernd Themann wrote:
>=20
> Is it valid (common in the kernel environment) to treat NULL as 0 aft=
er a memset
> and thus to forget about initialization?

Yes.  According to C99, "An implementation might conveivably have
codes for floating zero and/or null pointer other than all bits zero."
But as long as you don't use floating point (you shouldn't) and don't
redefine NULL to something other than (void*)0, this is rather
"inconceivable" for the kernel.

J=F6rn

--=20
Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it.
-- Brian W. Kernighan
