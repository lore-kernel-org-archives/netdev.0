From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 4/4] macvtap: Perform GSO on forwarding path.
Date: Tue, 25 Jun 2013 16:46:03 -0700 (PDT)
Message-ID: <20130625.164603.927051919262614736.davem@davemloft.net>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
	<1372190662-30815-5-git-send-email-vyasevic@redhat.com>
	<51C9FCB8.7070201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org, mst@redhat.com,
	eric.dumazet@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563Ab3FYXqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 19:46:04 -0400
In-Reply-To: <51C9FCB8.7070201@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 26 Jun 2013 00:25:28 +0400

> On 06/26/2013 12:04 AM, Vlad Yasevich wrote:
> 
>> +	} else
>> +		skb_queue_tail(&q->sk.sk_receive_queue, skb);
> 
>    According to Documentation/CodingStyle chapter 3, you should have {}
>    on both branches of *if* statement, if one branch has it.

I took care of this when applying the series.
