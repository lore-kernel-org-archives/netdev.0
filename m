From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Mon, 08 Jun 2009 17:06:08 +0200
Message-ID: <4A2D28E0.80508@trash.net>
References: <20090607151758.GB31757@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090607151758.GB31757@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> Passive OS fingerprinting netfilter module allows to passively detect
> remote OS and perform various netfilter actions based on that knowledge.
> This module compares some data (WS, MSS, options and it's order, ttl, df
> and others) from packets with SYN bit set with dynamically loaded OS
> fingerprints.

Applied, thanks. I've made one minor change:

--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -33,6 +33,7 @@ header-y += xt_limit.h
  header-y += xt_mac.h
  header-y += xt_mark.h
  header-y += xt_multiport.h
+header-y += xt_osf.h
  header-y += xt_owner.h
  header-y += xt_pkttype.h
  header-y += xt_quota.h
