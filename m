From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH 0/9] Replace rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
Date: Thu, 20 Mar 2014 15:58:52 +0100
Message-ID: <532B022C.8010505@broadcom.com>
References: <cover.1395324808.git.monamagarwal123@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <eddie.wai@broadcom.com>,
	<paulmck@linux.vnet.ibm.com>
To: Monam Agarwal <monamagarwal123@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395324808.git.monamagarwal123@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/03/14 15:37, Monam Agarwal wrote:
> This patchset uses following coccinelle script to replace
> rcu_assign_pointer(x, NULL) with RCU_INIT_POINTER(x,NULL)
>
> @@
> expression E;
> @@
> - rcu_assign_pointer(
> + RCU_INIT_POINTER(
> E, NULL)

I am not very familiar with rcu functionality nor coccinelle, but it 
looks too generic. I would think only NULL assignments during 
initialization should use RCU_INIT_POINTER(). The first patch in the 
series does it in a function called unregister_...(). Is it really ok to 
do there?

Gr. AvS
