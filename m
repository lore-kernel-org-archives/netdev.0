From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Vegas and tcp parameters per route
Date: Mon, 15 Mar 2004 13:30:34 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040315133034.487caee1@dell_ss3.pdx.osdl.net>
References: <20040312151729.25d9c696@dell_ss3.pdx.osdl.net>
	<1079160064.11606.15.camel@viivi>
	<20040315092018.1e843d83@dell_ss3.pdx.osdl.net>
	<20040315132214.4d9b5347.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pasi.sarolahti@iki.fi, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040315132214.4d9b5347.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Mon, 15 Mar 2004 13:22:14 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Mon, 15 Mar 2004 09:20:18 -0800
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > > Would it be too complicated, if sysctl would give the global default,
> > > from which one can deviate using RTAX_FEATURE?
> > 
> > Maybe for frto it needs to stay, but sysctl's are more painful and complex
> > than keeping the stuff in the routing info.  Also, the external tools are
> > part of every distro, except for a few embedded systems, the networking code
> > depends on user tools already.
> 
> How do you propose to support some kind of "global enable" for features.

The easiest way to do that is to initialize each TP with features from
sysctl when created.

> I think sysctl's support this quite well.  The test for the feature
> becomes "sysctl || route_attribute".

That is what the next version does for FRTO.

> Also, as Yoshfuji stated, you absolutely cannot change the existing
> sysctl numbers as tools that use the sysctl() system call use those
> numbers explicitly thus they are compiled into applications.

Okay, what about WESTWOOD?


> I really am not going to consider something that removes existing
> sysctl tunables. :-)

What about tcp_westwood which is new?
