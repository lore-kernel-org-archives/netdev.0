From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] openvswitch: add macro MODULE_ALIAS_VPORT_TYPE for
 vport type alias
Date: Sun, 04 Jun 2017 16:12:35 -0400 (EDT)
Message-ID: <20170604.161235.2303882939513535289.davem@davemloft.net>
References: <1496497655-24810-1-git-send-email-zhangshengju@cmss.chinamobile.com>
        <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zhangshengju@cmss.chinamobile.com, pshelar@nicira.com,
        netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49688 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751177AbdFDUMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 16:12:41 -0400
In-Reply-To: <CAOrHB_CjkyEoWVJFT5Q+vPOvcg4rd9cY+z5gRi7JEQscG6-dNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@ovn.org>
Date: Sat, 3 Jun 2017 22:58:22 -0700

> On Sat, Jun 3, 2017 at 6:47 AM, Zhang Shengju
> <zhangshengju@cmss.chinamobile.com> wrote:
>> Add a new macro MODULE_ALIAS_VPORT_TYPE to unify and simplify the
>> declaration of vport type alias, and replace magic numbers with
>> symbolic constants.
>>
>> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
>> ---
>>  net/openvswitch/vport-geneve.c | 2 +-
>>  net/openvswitch/vport-gre.c    | 2 +-
>>  net/openvswitch/vport-vxlan.c  | 2 +-
>>  net/openvswitch/vport.h        | 3 +++
>>  4 files changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/openvswitch/vport-geneve.c b/net/openvswitch/vport-geneve.c
>> index 5aaf3ba..1c068d6 100644
>> --- a/net/openvswitch/vport-geneve.c
>> +++ b/net/openvswitch/vport-geneve.c
>> @@ -141,4 +141,4 @@ static void __exit ovs_geneve_tnl_exit(void)
>>
>>  MODULE_DESCRIPTION("OVS: Geneve switching port");
>>  MODULE_LICENSE("GPL");
>> -MODULE_ALIAS("vport-type-5");
>> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GENEVE);
>> diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
>> index 0e72d95..48a5852 100644
>> --- a/net/openvswitch/vport-gre.c
>> +++ b/net/openvswitch/vport-gre.c
>> @@ -113,4 +113,4 @@ static void __exit ovs_gre_tnl_exit(void)
>>
>>  MODULE_DESCRIPTION("OVS: GRE switching port");
>>  MODULE_LICENSE("GPL");
>> -MODULE_ALIAS("vport-type-3");
>> +MODULE_ALIAS_VPORT_TYPE(OVS_VPORT_TYPE_GRE);
> 
> This is user visible change. For example this is changing the gre
> module alias from "vport-type-3" to "vport-type-OVS_VPORT_TYPE_GRE".
> This could break userspace application.

Agreed, you really can't do this.
