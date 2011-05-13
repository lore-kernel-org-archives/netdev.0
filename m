From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next 1/2 RESEND v3] net: use NETIF_F_ALL_TSO for vlan
 features
Date: Fri, 13 May 2011 10:10:21 +0800
Message-ID: <4DCC930D.80805@cn.fujitsu.com>
References: <4DCA2B86.9030205@cn.fujitsu.com> <4DCABABB.9040001@chelsio.com> <4DCBAE3B.3070201@cn.fujitsu.com> <4DCC1372.3040607@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eilong@broadcom.com,
	leedom@chelsio.com
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54013 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755761Ab1EMFoM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 01:44:12 -0400
In-Reply-To: <4DCC1372.3040607@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dimitris Michailidis wrote, at 2011=E5=B9=B405=E6=9C=8813=E6=97=A5 01:0=
5:
> But vlan_features doesn't indicate by itself what the device supports=
, and it is because of this that you can use NETIF_F_ALL_TSO in vlan_fe=
atures without much future breakage risk.  There's still the potential =
that in the future some additional TSO variant will be added that some =
of the drivers you're changing support, but not over VLANs, and then th=
ey'll need to undo you change.
=20
=46or this part.

David, please discard this patch.
=20
--=20
Best Regards
-----
Shan Wei
