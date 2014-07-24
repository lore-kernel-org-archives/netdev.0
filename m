From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v8 3/6] openvswitch: Add hash action
Date: Wed, 23 Jul 2014 18:02:50 -0700
Message-ID: <CALnjE+qcKjDi5a6m-QWRTEpokW-6rOR6Gbo7VFQCth5yXgofAA@mail.gmail.com>
References: <1406054089-1700-1-git-send-email-pshelar@nicira.com>
	<20140723.144248.119709569087635224.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:46049 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753304AbaGXBCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 21:02:50 -0400
Received: by mail-vc0-f174.google.com with SMTP id la4so3742073vcb.19
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2014 18:02:50 -0700 (PDT)
In-Reply-To: <20140723.144248.119709569087635224.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 23, 2014 at 2:42 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Tue, 22 Jul 2014 11:34:49 -0700
>
>> OVS_ACTION_ATTR_HASH is set to 10 to maintain compatibility with
>> existing userspace API.
>
> I don't understand this.
>
>> @@ -521,6 +544,7 @@ enum ovs_action_attr {
>>       OVS_ACTION_ATTR_PUSH_VLAN,    /* struct ovs_action_push_vlan. */
>>       OVS_ACTION_ATTR_POP_VLAN,     /* No argument. */
>>       OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
>> +     OVS_ACTION_ATTR_HASH = 10,     /* struct ovs_action_hash. */
>>       __OVS_ACTION_ATTR_MAX
>>  };
>
> Do you have to force this to skip to '10' because of something
> out-of-tree?  If so, that isn't a reasonable reason to do something
> like this, sorry.

ok, I will update patch.
