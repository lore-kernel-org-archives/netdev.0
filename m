From: David Miller <davem@davemloft.net>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Wed, 13 Oct 2010 14:58:56 -0700 (PDT)
Message-ID: <20101013.145856.112590240.davem@davemloft.net>
References: <20101012.130520.48517464.davem@davemloft.net>
	<20101013111946.GA9529@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, hans.schillstrom@ericsson.com,
	daniel.lezcano@free.fr, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47706
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753378Ab0JMV6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:58:34 -0400
In-Reply-To: <20101013111946.GA9529@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Wed, 13 Oct 2010 11:19:47 +0000

>> -static void rt_do_flush(int process_context)
>> +static void rt_do_flush(struct net *net, int process_context)
>>  {
>>  	unsigned int i;
>>  	struct rtable *rth, *next;
>> -	struct rtable * tail;
>>  
>>  	for (i = 0; i <= rt_hash_mask; i++) {
>> +		struct rtable *list, **pprev;
> 
> Isn't "list = NULL" needed here?

Yes it is, thanks for catching that.
