From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Wed, 17 Aug 2005 12:29:18 +0200
Message-ID: <4303117E.5000505@trash.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>	<42FC0F01.5090802@trash.net>	<20050812115622.GD16325@rama.de.gnumonks.org>
	<42FD4AC6.2020506@trash.net> <4301CB6D.80901@ufomechanic.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Amin Azez <azez@ufomechanic.net>
In-Reply-To: <4301CB6D.80901@ufomechanic.net>
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

Amin Azez wrote:
> Work well done, so oughtn't div64_64 to go in
> include/asm-generic/div64.h one day, to be available kernel wide, as
> do_div64_64
> 
> I see that net/core/pktgen.c is full of 64 bit division and maybe could
> benefit from this, and perhaps a version that does remainders too.

So far nothing besides ipt_connbytes and pktgen seems to need
it, and they use different versions. I'd rather leave it where
it is to not encourage more use of it.
