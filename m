From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch net-next 01/16] net: add dev arg to
 ndo_neigh_construct/destroy
Date: Tue, 5 Jul 2016 11:04:09 +0000
Message-ID: <CO2PR11MB0088E29053095135134B2BAB97390@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
 <1467710872-20056-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"yotamg@mellanox.com" <yotamg@mellanox.com>,
	"eladr@mellanox.com" <eladr@mellanox.com>,
	"nogahf@mellanox.com" <nogahf@mellanox.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"ivecera@redhat.com" <ivecera@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0097.outbound.protection.outlook.com ([104.47.32.97]:42736
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752103AbcGEMhl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:37:41 -0400
In-Reply-To: <1467710872-20056-2-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	int			(*ndo_neigh_construct)(struct neighbour *n);
> -	void			(*ndo_neigh_destroy)(struct neighbour *n);
> +	int			(*ndo_neigh_construct)(struct net_device
> *dev,
> +						       struct neighbour *n);
> +	void			(*ndo_neigh_destroy)(struct net_device *dev,
> +						     struct neighbour *n);

Perhaps leverage the fact you touch this and add a comment about this NDO?
