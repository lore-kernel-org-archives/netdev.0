From: "Gao Feng" <gfree.wind@vip.163.com>
Subject: RE: [PATCH net v4 00/12] Fix possbile memleaks when fail to register_netdevice
Date: Tue, 2 May 2017 19:10:29 +0800
Message-ID: <000b01d2c334$b6ccda80$24668f80$@vip.163.com>
References: <cover.1493699451.git.gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <jiri@resnulli.us>,
        <mareklindner@neomailbox.ch>, <sw@simonwunderlich.de>,
        <a@unstable.cc>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
        <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-177180.vip.163.com ([123.58.177.180]:53913 "EHLO
        mail-177180.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdEBLMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 07:12:52 -0400
In-Reply-To: <cover.1493699451.git.gfree.wind@foxmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

> From: gfree.wind@foxmail.com [mailto:gfree.wind@foxmail.com]
> Sent: Tuesday, May 2, 2017 1:59 PM
>  drivers/net/dummy.c             | 14 +++++++++++---
>  drivers/net/ifb.c               | 33 +++++++++++++++++++++++----------
>  drivers/net/loopback.c          | 15 ++++++++++++++-
>  drivers/net/team/team.c         | 15 ++++++++++++---
>  drivers/net/veth.c              | 15 ++++++++++++++-
>  net/8021q/vlan_dev.c            | 17 +++++++++++++----
>  net/batman-adv/soft-interface.c | 18 +++++++++++++++---
>  net/ipv4/ip_tunnel.c            | 11 ++++++++++-
>  net/ipv6/ip6_gre.c              | 17 +++++++++++++----
>  net/ipv6/ip6_tunnel.c           | 11 ++++++++++-
>  net/ipv6/ip6_vti.c              | 11 ++++++++++-
>  net/ipv6/sit.c                  | 17 +++++++++++++----
>  12 files changed, 158 insertions(+), 36 deletions(-)
> 
> --
>  v4: Make patches as one sery of patches, per David Miler
>  v3: Split one patch to multiple commits, per David Ahern
>  v2: Move the free in ndo_uninit when fail to register, per Herbert Xu
>  v1: initial version
> 
> 

Because I sent these patches too fast today, so that my email server blocks
my account today.
The left patches (08~12) would be sent after my account is unlocked. 

Maybe tomorrow.
I am very sorry about this, and try to change another mail server next time.

Best Regards
Feng
