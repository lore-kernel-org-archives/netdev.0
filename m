From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 16:10:31 +0100
Message-ID: <20041217151031.GA27170@atrey.karlin.mff.cuni.cz>
References: <1103247211.3071.74.camel@localhost.localdomain> <Xine.LNX.4.44.0412170012040.12382-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Fulton <bryan@coverity.com>, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261230AbULQPKh@vger.kernel.org>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0412170012040.12382-100000@thoron.boston.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> This at least needs CAP_NET_ADMIN.

Hmm, but that means that CAP_NET_ADMIN implies all other capabilities,
unless you fix this.

								Pavel

> > TAINTED variable "((tmp).num_counters * 16)" was passed to a tainted
> > sink.
> > 
> > 1161            counters = vmalloc(tmp.num_counters * sizeof(struct
> > ip6t_counters));
> > 1162            if (!counters) {
> > 1163                    ret = -ENOMEM;
> > 1164                    goto free_newinfo;
> > 1165            }
> > 
> > TAINTED variable "((tmp).num_counters * 16)" was passed to a tainted
> > sink.
> > 
> > 1166            memset(counters, 0, tmp.num_counters * sizeof(struct
> > ip6t_counters));


-- 
Boycott Kodak -- for their patent abuse against Java.
