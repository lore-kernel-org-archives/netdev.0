From: jamal <hadi@cyberus.ca>
Subject: Re: ing_filter debug messages
Date: 31 Dec 2004 10:03:53 -0500
Message-ID: <1104505432.1047.270.camel@jzny.localdomain>
References: <20041230160643.GD24603@wiggy.net>
	 <1104469666.1049.231.camel@jzny.localdomain>
	 <20041231093827.GG24603@wiggy.net>
	 <1104491510.1047.234.camel@jzny.localdomain>
	 <20041231131553.GA7460@wiggy.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20041231131553.GA7460@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-12-31 at 08:15, Wichert Akkerman wrote:
> Previously jamal wrote:
> > Does attached patch fix it?
> 
> No change at all I'm afraid . While rebooting to the kernel with that
> patch applied it got stuck in the shutdown sequence while repeating this
> line:
> 
> unregister_netdevice: waiting for xs4all for become free, Usage count = 1

I doubt this has anything to do with what i sent you. What i sent you is
certainly needed. Let me poke around for a few minutes - I am begining
to think theres a relation; the only way to be sure is to compile out
netfilter.

cheers,
jamal
