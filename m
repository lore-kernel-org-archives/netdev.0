From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] tproxy: fix hash locking issue when using port redirection
 in __inet_inherit_port()
Date: Thu, 21 Oct 2010 13:08:06 +0200
Message-ID: <4CC01F16.2000008@trash.net>
References: <20101020112142.6538.25550.stgit@este.odu> <20101020112142.6538.40476.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101020112142.6538.40476.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 20.10.2010 13:21, schrieb KOVACS Krisztian:
> When __inet_inherit_port() is called on a tproxy connection the wrong locks are
> held for the inet_bind_bucket it is added to. __inet_inherit_port() made an
> implicit assumption that the listener's port number (and thus its bind bucket).
> Unfortunately, if you're using the TPROXY target to redirect skbs to a
> transparent proxy that assumption is not true anymore and things break.
> 
> This patch adds code to __inet_inherit_port() so that it can handle this case
> by looking up or creating a new bind bucket for the child socket and updates
> callers of __inet_inherit_port() to gracefully handle __inet_inherit_port()
> failing.
> 
> Reported by and original patch from Stephen Buck <stephen.buck@exinda.com>.
> See http://marc.info/?t=128169268200001&r=1&w=2 for the original discussion.

Applied, thanks.
