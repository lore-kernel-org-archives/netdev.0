From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Mon, 09 Jun 2003 20:37:03 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609203659.089b241b.nakam@linux-ipv6.org>
References: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>
	<Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>,
   <vnuorval@tcs.hut.fi>, <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>,
   <netdev@oss.sgi.com>, <ajtuomin@morphine.tml.hut.fi>, <jagana@us.ibm.com>,
   <kumarkr@us.ibm.com>, <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Petander <lpetande@morphine.tml.hut.fi>
In-Reply-To: <Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Jun 2003 12:06:35 +0300 (EEST)
Henrik Petander <lpetande@morphine.tml.hut.fi> wrote:

> On Fri, 6 Jun 2003, Masahide NAKAMURA wrote:
> >
> > We don't think we have to change the logic handling policy with
> > the reason because we can treat MIPv6 policy just like IPsec.
> >
> > When we want to apply both MIPv6 and IPsec to the same target,
> > we need one policy that has two or more of templates(e.g. one is
> > MIPv6's template and the other is IPsec's).
> 
> Does this also mean that the IPSec and MIPv6 policies and SAs need to be
> configured at the same time or is it possible to add templates to an
> existing policy?

Currently no interface to add templates directly to it.

:
> A different issue related to the different addresses is that the SPD
> lookup should be done with the original source address, i.e. home address,
> if home address option is used and with the final destination address, if
> routing header is used. SPD lookup works now for TCP (with RT header), but
> not for raw sockets, which the mipv6 daemon will use. We will provide a
> patch for fixing the SPD lookups with raw sockets, which add routing
> header and home address option from socket options.
> 

Ok, I want to see your patch when it is provided because now I'm not so clear
about using socket option in the above case.

Regards,

-- 
Masahide NAKAMURA
