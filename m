From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipvs - avoid NULL ptr deref in __ip_vs_get_out_rt
Date: Tue, 11 Nov 2003 15:48:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111154832.1017f57f.davem@redhat.com>
References: <Pine.LNX.4.44.0311120134540.2506-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, wensong@linux-vs.org, morpheus@theendless.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0311120134540.2506-200000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 12 Nov 2003 01:46:43 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The attached patch fixes the problem as reported from
> Kris (morpheus at theendless.org) under subject "linux-2.6.0-test9 and 
> IPVS (Kernel OOPS) with sync daemon started.". Kris reported that
> the fix works. It fixes a copy-and-paste bug which leads to dereferencing 
> a NULL ptr in __ip_vs_get_out_rt.

Applied, thanks Julian.

I assume 2.4.x does not need this fix.
