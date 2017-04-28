From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net v2] net: dev: Fix possible memleaks when fail to register_netdevice
Date: Fri, 28 Apr 2017 23:34:48 +0800
Message-ID: <000001d2c034$f8db26f0$ea9174d0$@foxmail.com>
References: <1493349568-58635-1-git-send-email-gfree.wind@foxmail.com> <7d305254-03c5-0e6a-fac9-e9f4c758bf77@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "'David Ahern'" <dsahern@gmail.com>, <gfree.wind@foxmail.com>,
        <jiri@resnulli.us>, <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>,
        <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg62.qq.com ([103.7.29.139]:9971 "EHLO smtpbg64.qq.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1162851AbdD1PgG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 11:36:06 -0400
In-Reply-To: <7d305254-03c5-0e6a-fac9-e9f4c758bf77@gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Ahern [mailto:dsahern@gmail.com]
> Sent: Friday, April 28, 2017 11:23 PM
> On 4/27/17 9:19 PM, gfree.wind@foxmail.com wrote:
> >  drivers/net/dummy.c     | 14 +++++++++++---
> >  drivers/net/ifb.c       | 33 +++++++++++++++++++++++----------
> >  drivers/net/loopback.c  | 15 ++++++++++++++-
> drivers/net/team/team.c
> > | 15 ++++++++++++---
> >  drivers/net/veth.c      | 15 ++++++++++++++-
> >  net/8021q/vlan_dev.c    | 17 +++++++++++++----
> >  net/ipv4/ip_tunnel.c    | 11 ++++++++++-
> >  net/ipv6/ip6_gre.c      | 18 ++++++++++++++----
> >  net/ipv6/ip6_tunnel.c   | 11 ++++++++++-
> >  net/ipv6/ip6_vti.c      | 11 ++++++++++-
> >  net/ipv6/sit.c          | 17 +++++++++++++----
> >  11 files changed, 144 insertions(+), 33 deletions(-)
> 
> Seems like the changes to each file are completely independent, so they
should
> be in separate patches making each easier to review.

Thanks, I would like split them into multiple patches.

Best Regards
Feng
