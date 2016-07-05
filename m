From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: add dev arg to
 ndo_neigh_construct/destroy
Date: Tue, 5 Jul 2016 14:06:40 +0200
Message-ID: <20160705120640.GB1984@nanopsycho.orion>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
 <1467710872-20056-2-git-send-email-jiri@resnulli.us>
 <CO2PR11MB0088E29053095135134B2BAB97390@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
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
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37222 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbcGEMGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 08:06:43 -0400
Received: by mail-wm0-f47.google.com with SMTP id a66so149736422wme.0
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 05:06:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CO2PR11MB0088E29053095135134B2BAB97390@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 05, 2016 at 01:04:09PM CEST, Yuval.Mintz@qlogic.com wrote:
>> -	int			(*ndo_neigh_construct)(struct neighbour *n);
>> -	void			(*ndo_neigh_destroy)(struct neighbour *n);
>> +	int			(*ndo_neigh_construct)(struct net_device
>> *dev,
>> +						       struct neighbour *n);
>> +	void			(*ndo_neigh_destroy)(struct net_device *dev,
>> +						     struct neighbour *n);
>
>Perhaps leverage the fact you touch this and add a comment about this NDO?

Adding comment should be done in a separate patch. It is unrelated to
the change this patch does. Feel free to send a follow-up.
