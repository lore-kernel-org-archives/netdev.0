From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Mon, 15 Mar 2004 13:22:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315132214.4d9b5347.davem@redhat.com>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
	<1079160064.11606.15.camel@viivi>
	<20040315092018.1e843d83@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pasi.sarolahti@iki.fi, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040315092018.1e843d83@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 09:20:18 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> > Would it be too complicated, if sysctl would give the global default,
> > from which one can deviate using RTAX_FEATURE?
> 
> Maybe for frto it needs to stay, but sysctl's are more painful and complex
> than keeping the stuff in the routing info.  Also, the external tools are
> part of every distro, except for a few embedded systems, the networking code
> depends on user tools already.

How do you propose to support some kind of "global enable" for features.

I think sysctl's support this quite well.  The test for the feature
becomes "sysctl || route_attribute".

Also, as Yoshfuji stated, you absolutely cannot change the existing
sysctl numbers as tools that use the sysctl() system call use those
numbers explicitly thus they are compiled into applications.

I really am not going to consider something that removes existing
sysctl tunables. :-)
