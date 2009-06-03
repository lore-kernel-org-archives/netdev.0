From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next-2.6 1/1] e1000e: Expose MDI-X status via ethtool
	change
Date: Wed, 3 Jun 2009 14:04:27 -0700
Message-ID: <9929d2390906031404j51d9d158i319ba84121212a6e@mail.gmail.com>
References: <1243353768.3188.2.camel@achroite>
	 <20090527231542.GA19664@clala-laptop>
	 <1244050462.3191.14.camel@achroite> <4A26B6BC.40605@riverbed.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:61651 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752614AbZFCVE0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:04:26 -0400
Received: by yw-out-2324.google.com with SMTP id 5so144821ywb.1
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 14:04:28 -0700 (PDT)
In-Reply-To: <4A26B6BC.40605@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 3, 2009 at 10:45 AM, Chaitanya Lala <clala@riverbed.com> wr=
ote:
> Ben Hutchings wrote:
>>
>> On Wed, 2009-05-27 at 16:15 -0700, Chaitanya Lala wrote:
>> [...]
>>
>>>
>>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>>> index 380b042..b553bdb 100644
>>> --- a/include/linux/ethtool.h
>>> +++ b/include/linux/ethtool.h
>>> @@ -30,7 +30,8 @@ struct ethtool_cmd {
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 maxtxpkt; =C2=A0 =C2=A0 =C2=
=A0 /* Tx pkts before generating tx int */
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 maxrxpkt; =C2=A0 =C2=A0 =C2=
=A0 /* Rx pkts before generating rx int */
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u16 =C2=A0 speed_hi;
>>> - =C2=A0 =C2=A0 =C2=A0 __u16 =C2=A0 reserved2;
>>> + =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0is_mdix;
>>>
>>
>> Since this is specific to Ethernet over=EF=BB=BF twisted-pair cable,=
 could you
>> please rename this to "eth_tp_mdix".
>>
>
> Will do for sure.
>>
>>
>>>
>>> + =C2=A0 =C2=A0 =C2=A0 __u8 =C2=A0 =C2=A0reserved2;
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 lp_advertising; /* Features=
 the link partner advertises */
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0__u32 =C2=A0 reserved[2];
>>> =C2=A0};
>>> @@ -632,6 +633,11 @@ struct ethtool_ops {
>>> =C2=A0#define AUTONEG_DISABLE =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A00x00
>>> =C2=A0#define AUTONEG_ENABLE =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x01
>>> =C2=A0+/* Mode MDI or MDI-X */
>>> +#define MDI_INVALID 0x00
>>> +#define MDI =C2=A0 =C2=A0 =C2=A0 =C2=A0 0x01
>>> +#define MDI_X =C2=A0 =C2=A0 =C2=A0 0x02
>>>
>>
>> [...]
>>
>> Similarly, please add the prefix "ETH_TP_" to these.
>>
>
> Sure.

Chaitanya, I have made the requested changes to the patch in my tree.

--=20
Cheers,
Jeff
