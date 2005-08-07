From: Adrian Bunk <bunk@stusta.de>
Subject: Re: 2.6.13-rc4-mm1: iptables DROP crashes the computer
Date: Sun, 7 Aug 2005 19:23:33 +0200
Message-ID: <20050807172333.GF3513@stusta.de>
References: <7aaed091050807100843454603@mail.gmail.com>
	<7aaed09105080710121bba1b5b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux <linux-kernel@vger.kernel.org>, discuss@x86-64.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Espen =?iso-8859-1?Q?Fjellv=E6r?= Olsen <espenfjo@gmail.com>
Content-Disposition: inline
In-Reply-To: <7aaed09105080710121bba1b5b@mail.gmail.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 07, 2005 at 07:12:00PM +0200, Espen Fjellvær Olsen wrote:

> After execing "iptables -A INPUT -j DROP" my computer crashes hard. It
> dosent hang immediately, but after a couple of seconds.
> The machine is an amd64, running a clean x86_64 environment.
> uname -a: Linux gentoo 2.6.13-rc4-mm1 #1 PREEMPT Thu Aug 4 01:01:44
> CEST 2005 x86_64 AMD Athlon(tm) 64 Processor 3400+ AuthenticAMD
>...

Is this reproducible or did it happen only once?

Are there any messages that might give a hint where to search for the 
problem?

You are reporting this against 2.6.13-rc4-mm1, but are attaching a 
.config of 2.6.13-rc5-mm1. Which kernels are affected, and which are 
not?

Does it still happen if you compile your kernel with preemption 
disabled?

Please send the output of ./scripts/ver_linux .

> Mvh / Best regards
> Espen Fjellvær Olsen

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
