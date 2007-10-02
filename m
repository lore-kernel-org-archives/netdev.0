From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: Tue, 02 Oct 2007 16:53:04 +0200
Message-ID: <47025B50.4070501@hartkopp.net>
References: <20071002131006.31727.0@janus.isnogud.escape.de> <20071002131108.31727.3@janus.isnogud.escape.de> <20071002143001.GF7881@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:11020 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752217AbXJBOx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:53:29 -0400
In-Reply-To: <20071002143001.GF7881@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo wrote:
> Em Tue, Oct 02, 2007 at 03:10:09PM +0200, Urs Thuermann escreveu:
>   
>
>> +
>> +		if (ro->bound && ro->ifindex)
>> +			dev = dev_get_by_index(&init_net, ro->ifindex);
>>     
>
> dev_get_by_index can fail, are you sure that raw_enable_filters can cope
> with this possibility?
>
>   

When dev_get_by_index() fails, the netdev is not there anymore.
In this case the netdev notifier handler already set ro->bound to 0.

Additionally raw_enable_filters() can handle *dev even when it's NULL.

Oliver


