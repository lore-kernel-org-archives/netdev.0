From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] VXLAN: Precompute vin for VXLAN header.
Date: Tue, 26 Mar 2013 12:02:12 -0700
Message-ID: <CALnjE+pZyaP=PpRiwDq0aWzXoQ7WDVN+kOp8jkfvbzzbK0UVVA@mail.gmail.com>
References: <1364322539-27141-1-git-send-email-pshelar@nicira.com>
	<OF112514D1.BA5AC352-ON85257B3A.00666CE7-85257B3A.0066D5ED@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, jesse@nicira.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:46453 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755108Ab3CZTCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 15:02:13 -0400
Received: by mail-gh0-f198.google.com with SMTP id r11so5157455ghr.5
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 12:02:12 -0700 (PDT)
In-Reply-To: <OF112514D1.BA5AC352-ON85257B3A.00666CE7-85257B3A.0066D5ED@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 26, 2013 at 11:43 AM, David Stevens <dlstevens@us.ibm.com> wrote:
> netdev-owner@vger.kernel.org wrote on 03/26/2013 02:28:59 PM:
>  Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
>> @@ -1006,7 +1004,7 @@ static netdev_tx_t vxlan_xmit_one(struct
>> sk_buff *skb, struct net_device *dev,
>>
>>     vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
>>     vxh->vx_flags = htonl(VXLAN_FLAGS);
>> -   vxh->vx_vni = htonl(vni << 8);
>> +   vxh->vx_vni = vxlan->vni;
>
>         This is not correct since vni != vxlan->vni if an alternate
> vni is specified via the fdb entry. You would need to also store
> the fdb vni's as htonl(vni<<<8) and translate those back for netlink
> dump operations, too.
>
>                                                         +-DLS
>
Right I missed fdb vin , Let me send updated patch.

Thanks.
