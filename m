From: Chaitanya Lala <clala@riverbed.com>
Subject: Re: [PATCH net-next-2.6 1/1] e1000e: Expose MDI-X status via ethtool
 	change
Date: Wed, 03 Jun 2009 14:19:11 -0700
Message-ID: <4A26E8CF.50700@riverbed.com>
References: <1243353768.3188.2.camel@achroite>	 <20090527231542.GA19664@clala-laptop>	 <1244050462.3191.14.camel@achroite> <4A26B6BC.40605@riverbed.com> <9929d2390906031404j51d9d158i319ba84121212a6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.riverbed.com ([206.169.144.12]:46185 "EHLO
	smtp1.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbZFCVSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 17:18:16 -0400
In-Reply-To: <9929d2390906031404j51d9d158i319ba84121212a6e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> On Wed, Jun 3, 2009 at 10:45 AM, Chaitanya Lala <clala@riverbed.com> =
wrote:
>  =20
>> Ben Hutchings wrote:
>>    =20
>>> On Wed, 2009-05-27 at 16:15 -0700, Chaitanya Lala wrote:
>>> [...]
>>>
>>>      =20
>>>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>>>> index 380b042..b553bdb 100644
>>>> --- a/include/linux/ethtool.h
>>>> +++ b/include/linux/ethtool.h
>>>> @@ -30,7 +30,8 @@ struct ethtool_cmd {
>>>>        __u32   maxtxpkt;       /* Tx pkts before generating tx int=
 */
>>>>        __u32   maxrxpkt;       /* Rx pkts before generating rx int=
 */
>>>>        __u16   speed_hi;
>>>> -       __u16   reserved2;
>>>> +       __u8    is_mdix;
>>>>
>>>>        =20
>>> Since this is specific to Ethernet over=EF=BB=BF twisted-pair cable=
, could you
>>> please rename this to "eth_tp_mdix".
>>>
>>>      =20
>> Will do for sure.
>>    =20
>>>      =20
>>>> +       __u8    reserved2;
>>>>        __u32   lp_advertising; /* Features the link partner advert=
ises */
>>>>        __u32   reserved[2];
>>>>  };
>>>> @@ -632,6 +633,11 @@ struct ethtool_ops {
>>>>  #define AUTONEG_DISABLE                0x00
>>>>  #define AUTONEG_ENABLE         0x01
>>>>  +/* Mode MDI or MDI-X */
>>>> +#define MDI_INVALID 0x00
>>>> +#define MDI         0x01
>>>> +#define MDI_X       0x02
>>>>
>>>>        =20
>>> [...]
>>>
>>> Similarly, please add the prefix "ETH_TP_" to these.
>>>
>>>      =20
>> Sure.
>>    =20
>
> Chaitanya, I have made the requested changes to the patch in my tree.
>
>  =20
Thanks. I am very new to procedure of submitting kernel patches. Just=20
want to make sure if this means that I not need to send another patch t=
o=20
netdev ?

Thanks,
Chaitanya
