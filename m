From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [PATCH 1/6] ehea: interface to network stack
Date: Mon, 14 Aug 2006 13:26:56 +0200
Message-ID: <20060814112656.GC10164@wohnheim.fh-wedel.de>
References: <44D99EFC.3000105@de.ibm.com> <20060811205624.GE479@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan-Bernd Themann <ossthema@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wohnheim.fh-wedel.de ([213.39.233.138]:21991 "EHLO
	wohnheim.fh-wedel.de") by vger.kernel.org with ESMTP
	id S1751993AbWHNL1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 07:27:08 -0400
To: Anton Blanchard <anton@samba.org>
Content-Disposition: inline
In-Reply-To: <20060811205624.GE479@krispykreme>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 August 2006 06:56:24 +1000, Anton Blanchard wrote:
>=20
> > +
> > +				skb_index =3D ((index - i
> > +					      + port_res->skb_arr_sq_len)
> > +					     % port_res->skb_arr_sq_len);
>=20
> This is going to force an expensive divide. Its much better to change
> this to the simpler and quicker:
>=20
> i++;
> if (i > max)
> 	i =3D 0;

Is a conditional cheaper than a divide?  In case of a misprediction I
would assume it to be significantly slower and I don't know the ratio
of mispredictions for this branch.

J=F6rn

--=20
Victory in war is not repetitious.
-- Sun Tzu
