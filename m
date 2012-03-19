From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] adjust __net_exit
Date: Mon, 19 Mar 2012 09:47:03 +0100
Message-ID: <20120319084703.GA20897@merkur.ravnborg.org>
References: <4F588BEC020000780007710A@nat28.tlf.novell.com> <20120316.221813.236130733754848615.davem@davemloft.net> <20120317230318.GA19460@merkur.ravnborg.org> <4F66F8F70200007800079305@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, xemul@openvz.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	ebiederm@xmission.com
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F66F8F70200007800079305@nat28.tlf.novell.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> > Using the (bogus and unused elsewhere)
> >> > __exit_refok to implement this is inefficient - any non-modular code
> >> > really can reside in __init (as non-modular __exit code is never used).

> > 2) fix up the bogus commit message
> 
> Bogus in what way?

I fail to see that __exit_refok is bogus.
The name is not optimal - which is why is is deprecated.

	Sam
