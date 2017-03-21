From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Tue, 21 Mar 2017 15:36:06 -0700 (PDT)
Message-ID: <20170321.153606.2138520242577188528.davem@davemloft.net>
References: <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
	<CAGXu5j+HK6jXeA3EdJGMLK_7o04AiTwXmmjuKOmExz0g5rs=kw@mail.gmail.com>
	<1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: keescook@chromium.org, peterz@infradead.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	jmorris@namei.org, ishkamiel@gmail.com, kuznet@ms2.inr.ac.ru,
	akpm@linux-foundation.org, dwindsor@gmail.com, kaber@trash.net,
	elena.reshetova@intel.com, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1490131389.16816.123.camel@edumazet-glaptop3.roam.corp.google.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 21 Mar 2017 14:23:09 -0700

> It looks like our suggestion to get kernel builds with atomic_inc()
> being exactly an atomic_inc() is not even discussed or implemented.
> 
> Coding this would require less time than running a typical Google kernel
> qualification (roughly one month, thousands of hosts..., days of SWE).

+1
