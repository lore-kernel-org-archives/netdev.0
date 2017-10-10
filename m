From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] openvswitch: add ct_clear action
Date: Tue, 10 Oct 2017 16:38:43 -0700 (PDT)
Message-ID: <20171010.163843.751844479764203819.davem@davemloft.net>
References: <20171010205444.20628-1-e@erig.me>
        <CAOrHB_AMzr-1uTRfE_xWLdTPwUPoz1Dwoobp3P1BkqQeL3qGzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: e@erig.me, netdev@vger.kernel.org, dev@openvswitch.org, joe@ovn.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753333AbdJJXiq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 19:38:46 -0400
In-Reply-To: <CAOrHB_AMzr-1uTRfE_xWLdTPwUPoz1Dwoobp3P1BkqQeL3qGzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@ovn.org>
Date: Tue, 10 Oct 2017 16:34:29 -0700

> On Tue, Oct 10, 2017 at 1:54 PM, Eric Garver <e@erig.me> wrote:
>> This adds a ct_clear action for clearing conntrack state. ct_clear is
>> currently implemented in OVS userspace, but is not backed by an action
>> in the kernel datapath. This is useful for flows that may modify a
>> packet tuple after a ct lookup has already occurred.
>>
>> Signed-off-by: Eric Garver <e@erig.me>
>> ---
>> v2:
>>         - Use IP_CT_UNTRACKED for nf_ct_set()
>>         - Only fill key if previously conntracked
>>
> Looks good.
> Acked-by: Pravin B Shelar <pshelar@ovn.org>

Applied.
