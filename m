From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: CONFIG_IPV6_SUBTREES (was [patch]: CONFIG_IPV6_SUBTREES fix for
 MIPv6)
Date: Fri, 6 Jun 2003 14:16:57 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306061404030.3737-100000@rhea.tcs.hut.fi>
References: <20030606.193218.117654914.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Cc: davem@redhat.com, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
   <ajtuomin@morphine.tml.hut.fi>, <lpetande@morphine.tml.hut.fi>,
   <jagana@us.ibm.com>, <kumarkr@us.ibm.com>, <nakam@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030606.193218.117654914.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> Excuse me, please forget anything related to "Mobile IP" during this
> discussion; do not assume that Mobile IP is the only user of
> CONFIG_IPV6_SUBTREES.

At the moment it is  :)

I was just making a point about the IMHO flawed semantics of
CONFIG_IPV6_SUBTREES.

If you keep the original (first dest, then src) key ordering you
basically can't use the subtrees for anything else but storing source
address specific host routes.

With the reversed order you can do a lot more...

-Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
