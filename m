From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipvs - avoid returning NF_DROP from the packet
 schedulers
Date: Wed, 8 Oct 2003 08:48:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008084833.0efcc4e1.davem@redhat.com>
References: <Pine.LNX.4.44.0310081101170.5889-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, rusty@rustcorp.com.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310081101170.5889-200000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 11:09:20 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	It seems my NF_DROP approach leads to new bugs. So, better
> free skb, return NF_STOLEN and add some comments. If someone
> wants to fix it in another way, go ahead.

Applied, thanks.
