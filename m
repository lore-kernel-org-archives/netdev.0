From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v2] net: cxgb4{,vf}: convert to hw_features
Date: Sun, 17 Apr 2011 01:04:47 +0200
Message-ID: <20110416230447.GA23852@rere.qmqm.pl>
References: <20110415145050.6A43913A6A@rere.qmqm.pl> <20110416165226.B881F13A65@rere.qmqm.pl> <4DA9DEBF.8050300@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47568 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab1DPXEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 19:04:48 -0400
Content-Disposition: inline
In-Reply-To: <4DA9DEBF.8050300@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 16, 2011 at 11:23:59AM -0700, Dimitris Michailidis wrote:
> Micha=B3 Miros=B3aw wrote:
>> Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
>> ---
>> v2: cxgb4: remove now unneeded variable in t4_ethrx_handler()
>>     cxgb4vf: fix hw/vlan_features values
>
> Thanks for doing this.  The cxgb4 part looks good.  For cxgb4vf I hav=
e a =20
> comment below.
>
>> @@ -2638,19 +2597,18 @@ static int __devinit cxgb4vf_pci_probe(struc=
t pci_dev *pdev,
>> -		netdev->features =3D (NETIF_F_SG | TSO_FLAGS |
>> -				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>> -				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
>> -				    NETIF_F_GRO);
>> +		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS | NETIF_F_RXCSUM |
>> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
>> +		netdev->vlan_features =3D NETIF_F_SG | TSO_FLAGS |
>> +			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
>> +			NETIF_F_HW_VLAN_TX | NETIF_F_HIGHDMA;
>
> This NETIF_F_HW_VLAN_TX looks misplaced.  Did you mean to add it to =20
> hw_features rather than vlan_features?

Yes. You're right! [v3 following]

Best Regards,
Micha=B3 Miros=B3aw
