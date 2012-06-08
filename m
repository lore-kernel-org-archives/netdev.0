From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Fri, 08 Jun 2012 18:56:12 +0300
Message-ID: <67d8beaf421874815145fdefc69b3366@visp.net.lb>
References: <7ed49f446365ac625437702d92946add@visp.net.lb>
 <20120607205356.GA2491@electric-eye.fr.zoreil.com>
 <1339104606.6001.4.camel@edumazet-glaptop>
 <20120607223752.GA4475@electric-eye.fr.zoreil.com>
 <1339134438.6001.13.camel@edumazet-glaptop>
 <20120608154106.GD5024@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120608154106.GD5024@kvack.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-06-08 18:41, Benjamin LaHaise wrote:
> On Fri, Jun 08, 2012 at 07:47:18AM +0200, Eric Dumazet wrote:
>> I have no idea how many l2tp_eth devices are setup at once in 
>> typical
>> conf.
>
> Depends on the usage scenario.  L2TP is commonly used for terminating
> customer connections by wholesale ISPs.  In that kind of edge routing
> use-case, tens of thousands of interfaces are easily possible.
>
> 		-ben
In my case it is few hundreds. I am not sure it is typical case, but i 
really will like if this setup
will give me good performance. Since Linux usually used on the PC's, i 
don't think they will scale more
than 2-3 Gbps. Also L2TP pseudowire (l2tp_eth) usually done not 
directly to end-users, but to LAC's, so i think
it is up to thousand.

Right now i am routing around 700Mbps over there, and noticed some 
problem with pskb_expand_head,
but that's separate question i will ask, if i will not be able to sort 
it out by myself.


---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
