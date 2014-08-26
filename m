From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v3 04/12] net: dsa: retain a per-port device_node
 pointer
Date: Mon, 25 Aug 2014 17:51:19 -0700
Message-ID: <53FBDA07.70403@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com> <1408905869-10471-5-git-send-email-f.fainelli@gmail.com> <53FA7607.1080906@gmail.com> <53FA9FB4.9050801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34875 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606AbaHZAvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 20:51:49 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so22165209pab.28
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 17:51:49 -0700 (PDT)
In-Reply-To: <53FA9FB4.9050801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/24/2014 07:30 PM, Florian Fainelli wrote:
> Le 24/08/2014 16:32, Alexander Duyck a =C3=A9crit :
>> On 08/24/2014 11:44 AM, Florian Fainelli wrote:
>>> We will later use the per-port device_node pointer to fetch a bunch=
 of
>>> port-specific properties.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>>   include/net/dsa.h | 1 +
>>>   net/dsa/dsa.c     | 2 ++
>>>   net/dsa/slave.c   | 1 +
>>>   3 files changed, 4 insertions(+)
>>>
>>> diff --git a/include/net/dsa.h b/include/net/dsa.h
>>> index 91d5ba435ab6..66bb036831fd 100644
>>> --- a/include/net/dsa.h
>>> +++ b/include/net/dsa.h
>>> @@ -41,6 +41,7 @@ struct dsa_chip_data {
>>>        * or any other string to indicate this is a physical port.
>>>        */
>>>       char        *port_names[DSA_MAX_PORTS];
>>> +    struct device_node *port_dn[DSA_MAX_PORTS];
>>>
>>>       /*
>>>        * An array (with nr_chips elements) of which element [a]
>>
>> It might make sense to place name and device_node pointers members o=
f a
>> port struct, and move that array of structs to the end of the
>> dsa_chip_data structure.
>=20
> That's a good point, I will fix that.

I just realized that this structure is also used in arch/arm/* and
arch/blackfin/*. While I can compile test this, I am kind of reluctant
to make this change just now, maybe a little later in the net-next merg=
e
window, if that sounds okay with you?

Thanks
--
=46lorian
