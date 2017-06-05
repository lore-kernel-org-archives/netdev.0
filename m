From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for vport type alias
Date: Mon, 5 Jun 2017 09:10:22 +0800
Message-ID: <001601d2dd98$8209e620$861db260$@cmss.chinamobile.com>
References: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com>       <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com> <20170604.161235.2303882939513535289.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <pshelar@nicira.com>, <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>, <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:59046 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751193AbdFEBK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 21:10:26 -0400
In-Reply-To: <20170604.161235.2303882939513535289.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, June 05, 2017 4:13 AM
> To: pshelar@ovn.org
> Cc: zhangshengju@cmss.chinamobile.com; pshelar@nicira.com;
> netdev@vger.kernel.org
> Subject: Re: [net-next] openvswitch: add macro
> MODULE_ALIAS_VPORT_TYPE for vport type alias
> 
> From: Pravin Shelar <pshelar@ovn.org>
> Date: Sat, 3 Jun 2017 22:58:22 -0700
> 
> > On Sat, Jun 3, 2017 at 6:47 AM, Zhang Shengju
> > <zhangshengju@cmss.chinamobile.com> wrote:
> >> Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
> >> declaration of vport type alias, and replace magic numbers with
> >> symbolic constants.
> >>
> >> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> >> ---
> >>  net/openvswitch/vport-geneve.c | 2 +-
> >>  net/openvswitch/vport-gre.c    | 2 +-
> >>  net/openvswitch/vport-vxlan.c  | 2 +-
> >>  net/openvswitch/vport.h        | 3 +++
> >>  4 files changed, 6 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/net/openvswitch/vport-geneve.c
> >> b/net/openvswitch/vport-geneve.c index 5aaf3ba..1c068d6 100644
> >> --- a/net/openvswitch/vport-geneve.c
> >> +++ b/net/openvswitch/vport-geneve.c
> >> @@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
> >>
> >>  MODULE_DESCRIPTION("OVS: Geneve switching port");
> >> MODULE_LICENSE("GPL"); -MODULE_ALIAS("vport-type-5");
> >> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GENEVE);
> >> diff --git a/net/openvswitch/vport-gre.c
> >> b/net/openvswitch/vport-gre.c index 0e72d95..48a5852 100644
> >> --- a/net/openvswitch/vport-gre.c
> >> +++ b/net/openvswitch/vport-gre.c
> >> @@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
> >>
> >>  MODULE_DESCRIPTION("OVS: GRE switching port");
> >> MODULE_LICENSE("GPL"); -MODULE_ALIAS("vport-type-3");
> >> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GRE);
> >
> > This is user visible change. For example this is changing the gre
> > module alias from "vport-type-3" to "vport-type-OVS_VPORT_TYPE_GRE".
> > This could break userspace application.
> 
> Agreed, you really can't do this.

Hi David,
Actually this change does not change module alias name. I use '__stringify'
to 
address this.  Please refer my previous reply.

BRs,
Zhang Shengju
