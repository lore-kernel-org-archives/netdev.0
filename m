From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net/3.9] ipv6: ndisc: fix ndisc_send_redirect writing
 to the wrong skb
Date: Fri, 31 May 2013 01:42:44 -0700 (PDT)
Message-ID: <20130531.014244.1871655049070137342.davem@davemloft.net>
References: <51A66CF3.7010202@universe-factory.net>
	<5578958b49fff222740711e091c2325100f5a440.1369963643.git.mschiffer@universe-factory.net>
	<CAM_iQpWNAnRTgzjPTPxLU-eqz1nWqD=zyjTgwZaaxbwcpf4KMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschiffer@universe-factory.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34714 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab3EaImp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 04:42:45 -0400
In-Reply-To: <CAM_iQpWNAnRTgzjPTPxLU-eqz1nWqD=zyjTgwZaaxbwcpf4KMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 31 May 2013 11:23:11 +0800

> On Fri, May 31, 2013 at 9:27 AM, Matthias Schiffer
> <mschiffer@universe-factory.net> wrote:
>> Since some refactoring in 5f5a011, ndisc_send_redirect called
>> ndisc_fill_redirect_hdr_option on the wrong skb, leading to data corruption or
>> in the worst case a panic when the skb_put failed.
>>
>> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
> 
> 
> Good catch!
> 
> Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

I've queued this up for -stable.
