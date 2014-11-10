From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Mon, 10 Nov 2014 11:28:57 -0500 (EST)
Message-ID: <20141110.112857.1873381550982989519.davem@davemloft.net>
References: <54603270.509@mojatatu.com>
	<20141110074344.GB1850@nanopsycho.orion>
	<5460ACC0.3020805@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaKJQ3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 11:29:02 -0500
In-Reply-To: <5460ACC0.3020805@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Mon, 10 Nov 2014 07:17:04 -0500

> On 11/10/14 02:43, Jiri Pirko wrote:
>> Mon, Nov 10, 2014 at 04:35:12AM CET, jhs@mojatatu.com wrote:
> 
>> I don't see a reason why this would break kabi:
>>
>> -#define MAX_PHYS_PORT_ID_LEN 32
>> +#define MAX_PHYS_ITEM_ID_LEN 32
>>
> 
> refer to my response to Dave. Just define MAX_PHYS_PORT_ID_LEN to
> MAX_PHYS_ITEM_ID_LEN so people dont have to change their code
> because a name change.

Again, nobody has to change anything.

This macro is not visible outside of the kernel.

Jamal, this is really driving me crazy, this is a non-issue.
