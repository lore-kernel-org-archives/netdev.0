From: Patrick McHardy <kaber@trash.net>
Subject: Re: Two comments on the H.323 conntrack/NAT helper
Date: Fri, 24 Mar 2006 03:02:12 +0100
Message-ID: <44235324.3080607@trash.net>
References: <20060324001307.GO22727@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zhaojingmin@users.sourceforge.net,
	netfilter-devel@lists.netfilter.org,
	Jing Min Zhao <zhaojignmin@hotmail.com>, linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060324001307.GO22727@stusta.de>
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

[The hotmail address of the author doesn't work, CCed sourceforge-address]

Adrian Bunk wrote:
> Two comments on the H.323 conntrack/NAT helper:
> - the function prototypes in ip_nat_helper_h323.c are _ugly_,
>   please move them to a header file

Their ugliness is because of the current API, which cleaned up
quite a lot of the surrounding code, but requires this ugliness
from each helper. I would like to keep them visible as a reminder
that a cleaner solution is wanted, but moving them to header
files certainly sound like a good idea to eliminate the risk
of prototype conflicts. But please do this for all helpers
at once.

> - is there a reason for not using EXPORT_SYMBOL_GPL?

I would prefer that too.
