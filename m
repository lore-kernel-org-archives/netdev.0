From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: ixgbe dump
Date: Mon, 22 Nov 2010 20:18:20 -0800
Message-ID: <29F4ED941D916B48B88B4D2A4F3D1B9C01CC08FBDD@orsmsx509.amr.corp.intel.com>
References: <4CE47FA6.8050600@kernel.org>
	<29F4ED941D916B48B88B4D2A4F3D1B9C01CBFC68C5@orsmsx509.amr.corp.intel.com>
	<AANLkTinQ-6CaUY3bYd+SMBCaNvU5YiXL2P+gh7N1tM-x@mail.gmail.com>
	<1290468133.2603.2.camel@jtkirshe-MOBL1>
	<AANLkTi=Esp=y2ci=RrCeXYVaxnbrJY3NXpaBgPOBqc7p@mail.gmail.com>
	<29F4ED941D916B48B88B4D2A4F3D1B9C01CC08FBCF@orsmsx509.amr.corp.intel.com>
 <AANLkTi=ceFYmLuqYhWxyoQ2A3Wev6Dw7V2U+sc-D8d9_@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:23725 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350Ab0KWESd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 23:18:33 -0500
In-Reply-To: <AANLkTi=ceFYmLuqYhWxyoQ2A3Wev6Dw7V2U+sc-D8d9_@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: yhlu.kernel@gmail.com [mailto:yhlu.kernel@gmail.com] On Behalf O=
f
>Yinghai Lu
>Sent: Monday, November 22, 2010 8:16 PM
>To: Skidmore, Donald C
>Cc: Kirsher, Jeffrey T; Brandeburg, Jesse; David Miller; NetDev
>Subject: Re: ixgbe dump
>
>On Mon, Nov 22, 2010 at 7:31 PM, Skidmore, Donald C
><donald.c.skidmore@intel.com> wrote:
>>
>> Hi Yinghai,
>>
>> I was hoping we could have had this patch pushed upstream sooner, bu=
t we
>have quite a few in our internal queue right now.
>>
>> If this doesn't solve your issue please let me know.
>>
>> Thanks,
>> -Don Skidmore <donald.c.skidmore@intel.com>
>>
>>
>>
>>
>> After freeing the rings we were not zeroing out the ring count value=
s.
>> This patch now clears these counts correctly.
>>
>> Reported-by: Yinghai Lu <yinghai@kernel.org>
>> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
>> ---
>>
>> =A0drivers/net/ixgbe/ixgbe_main.c | =A0 =A03 +++
>> =A01 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ixgbe/ixgbe_main.c
>b/drivers/net/ixgbe/ixgbe_main.c
>> index fbad4d8..eee0b29 100644
>> --- a/drivers/net/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ixgbe/ixgbe_main.c
>> @@ -4771,6 +4771,9 @@ void ixgbe_clear_interrupt_scheme(struct
>ixgbe_adapter *adapter)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0adapter->rx_ring[i] =3D NULL;
>> =A0 =A0 =A0 =A0}
>>
>> + =A0 =A0 =A0 adapter->num_tx_queues =3D 0;
>> + =A0 =A0 =A0 adapter->num_rx_queues =3D 0;
>> +
>> =A0 =A0 =A0 =A0ixgbe_free_q_vectors(adapter);
>> =A0 =A0 =A0 =A0ixgbe_reset_interrupt_capability(adapter);
>> =A0}
>
>OK, that fix the problem.
>
>Thanks
>
>Yinghai

That great to hear.  Hopefully we will be able to get the patch submitt=
ed  soon.

Thanks,
-Don
