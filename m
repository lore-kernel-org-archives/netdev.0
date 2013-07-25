From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Hack bench regression with CONFIG_SLUB_CPU_PARTIAL disabled
 (info only)
Date: Thu, 25 Jul 2013 04:05:59 -0700
Message-ID: <1374750359.23313.17.camel@edumazet-glaptop>
References: <51F0DB11.2080508@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51F0DB11.2080508@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-07-25 at 13:30 +0530, Raghavendra K T wrote:
> Hi,
> 
> While testing hackbench with 3.11-rc1 I observed hackbench testcase
> took too long to complete (32 vcpu kvm guest on 32 core HT off machine).
> 
> hackbench 1x degraded by 3 time (40sec vs 112sec)
> hackbench 2x degraded by around 20time (90sec vs 1800 sec)
> 
> When I bisected, I found that I had CONFIG_SLUB_CPU_PARTIAL
> accidentally disabled.
> I understand that  CONFIG_SLUB_CPU_PARTIAL=y by default and the config
> option is to provide determinism for RT kernels and thus it is not a
> problem.
> But thought of sharing this here so that if somebody runs into same 
> issue accidently, it would save their time.

Incidentally, what difference do you currently get with SLUB and SLAB ?
