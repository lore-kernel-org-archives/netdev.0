From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: iwlwifi worse than ever in current git.
Date: Thu, 19 Jan 2012 08:47:28 +0200
Message-ID: <CANUX_P3UHz-Pr_M1H5pAbmKDY70es7nxkWSDGXG6-hvrPAMCJw@mail.gmail.com>
References: <20120110184917.GA26973@redhat.com>
	<1326221614.5067.6.camel@dcbw.foobar.com>
	<0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
	<20120111014243.GA22066@redhat.com>
	<0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
	<20120111195055.GA5140@redhat.com>
	<0BA3FCBA62E2DC44AF3030971E174FB3064AF5@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB3064AF5-yLYCJVCiOGwLt2AQoY/u9bfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>>
>> [16520.224964] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proce=
ed: ssn =3D
>> next_recl =3D 124
>> [16520.228038] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11 =A0=
WrPtr: 124
>> [16520.228358] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status=
 Activate
>> BA Queue 11 on FIFO 1
>> [16520.229059] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =3D
>> b8:c7:5d:0c:39:87 tid =3D 0
>> [16531.888296] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can procee=
d: ssn =3D
>> next_recl =3D 631
>> [16531.888793] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11 =A0=
WrPtr: 0
>> [16531.889247] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status
>> Deactivate AC/CMD Queue 11 on FIFO 0
>> [16552.504609] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proce=
ed: ssn =3D
>> next_recl =3D 697
>> [16552.508182] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11 =A0=
WrPtr: 185
>> [16552.508609] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status=
 Activate
>> BA Queue 11 on FIFO 1
>> [16552.509077] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =3D
>> b8:c7:5d:0c:39:87 tid =3D 0
>> [16564.084058] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can procee=
d: ssn =3D
>> next_recl =3D 1241
>> [16564.084506] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11 =A0=
WrPtr: 0
>> [16564.084903] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status
>> Deactivate AC/CMD Queue 11 on FIFO 0
>> [16568.975872] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proce=
ed: ssn =3D
>> next_recl =3D 1298
>> [16568.978796] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11 =A0=
WrPtr: 18
>> [16568.979007] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status=
 Activate
>> BA Queue 11 on FIFO 1
>> [16568.979734] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra =3D
>> b8:c7:5d:0c:39:87 tid =3D 0
>> [16580.004052] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proc=
eed: ssn
>> 1491, next_recl =3D 150
>>
>
> I understand there is nothing afterwards... This is really weird. The=
 sequence numbers here are really crazy...
> I need to think that over.
>
>>

Ok, I finally had a change to take a closer look at this. Please run
with debug=3D0xC0000000.

This will be noisy, but I guess we have no choice...
I will be travelling next week, so...
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
