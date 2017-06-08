From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH 1/2] ip_tunnel: fix potential issue in ip_tunnel_rcv
Date: Thu, 8 Jun 2017 08:10:07 +0800
Message-ID: <E030598F-13EC-4816-965E-FC24D86DA5CF@cmss.chinamobile.com>
References: <1496844976-15282-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1496846893.736.41.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496846893.736.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 7 Jun 2017, at 10:48 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> On Wed, 2017-06-07 at 22:16 +0800, Haishuang Yan wrote:
>> When ip_tunnel_rcv fails, the tun_dst won't be freed, so move
>> skb_dst_set to begin and tun_dst would be freed by kfree_skb.
>> 
>> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
>> ---
> 
> Please add the missing Fixes: tag and CC author of the patch that added
> this bug, so that he has a chance to comment and avoid future similar
> bugs.
> 
> Thanks.
> 
> 
> 

Ok, I will add these information in v2 commit.
Thanks.
