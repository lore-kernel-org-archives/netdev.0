From: jamal <hadi@cyberus.ca>
Subject: Re: is there any plan to support BSD accept filter?
Date: 16 Jan 2005 09:43:21 -0500
Message-ID: <1105886601.1097.583.camel@jzny.localdomain>
References: <41E830BC.7000709@cs.princeton.edu>
	 <20050114140540.76146b29@dxpl.pdx.osdl.net>
	 <41E87E7D.8040107@cs.princeton.edu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: KyoungSoo Park <kyoungso@cs.princeton.edu>
In-Reply-To: <41E87E7D.8040107@cs.princeton.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Seems easy to do if you can muck with the security hooks.
The selinux folkk already have a monopoly on all those hooks.
Look at selinux and security_socket_accept() and how you can hook up
to it. You probably wanna worry about security_socket_recvmsg() and
security_socket_post_accept()
Dont ask me - look at the code and visit their docs. As a warning those
hooks are pretty stupid (what a waste of potential) so you will have to
sweat a little hacking them to maintain state.

cheers,
jamal

On Fri, 2005-01-14 at 21:22, KyoungSoo Park wrote:
> yes. I agree that maybe an ugly hack to put that in the kernel.
> What I want to do is to support such feature leaving as little footprint
> as possible in the kernel, but specify whatever flexible policy you want
> in the user level. 
> I'm not sure netfilter module is the right place because it seems I need 
> to do packet by packet processing, but I want to deal with a little higher
> level than that as a start. (I'm not familar with netfilter, so please correct
> me if I'm wrong.)
> 
> Anyway, thanks for your response.
> 
> KyoungSoo
> 
> 
> Stephen Hemminger wrote:
> 
> >If you want to do these kind of stateful hacks, why not build a
> >netfilter module to do it?
> >
> >
> >  
> >
> 
> 
> 
