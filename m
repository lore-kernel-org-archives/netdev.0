From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH net-2.6.24] s2io: sparse warnings fix (rev2)
Date: Wed, 10 Oct 2007 21:27:11 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD770257FACC@nekter>
References: <20071005123921.137a9e4e@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Ramkrishna Vepa" <ram.vepa@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	<netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:5185 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbXJKBn2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 21:43:28 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071005123921.137a9e4e@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

> Fix warnings from sparse checker about shadowed definition and
improperly
> formatted ethtool_strings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>   CHECK   drivers/net/s2io.c
> - * lro: Specifies whether to enable Large Receive Offload (LRO) or
not.
> + * lro_enable: Specifies whether to enable Large Receive Offload
(LRO) or
> not.
This change is not required since the name is not changed. Rest looks
fine.

Ram
