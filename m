From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: 17 Jul 2003 02:39:02 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058398742.5778.26.camel@hades>
References: <200307162328.DAA12405@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307162328.DAA12405@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-07-17 at 02:28, kuznet@ms2.inr.ac.ru wrote:
> > While I see where you're coming from, I don't really understand what the
> > fuss is all about.
> 
> The issue definitely does not worth of time already spent for the discussion.

I agree. :)

> All the fuss is about the fact that this code lived and will live for years.
> If we allowed to add small tricks of this kind, it would end up as a full mess.
> Each convenience trick must have a logical background.

So what's the background for having the hack to specify a tunnel EP with
a gateway route?

> I have been asked for an opinion, this is my opinion: 6to4 is wrong,
> addresses in format of 6over4 are natural, if they are deprecated,
> another and even more natural variant is use of link-local format,
> fe80::a.b.c.d.

IPv4-mapped would be semantically correct. It definately can't be
confused with any real IPv6 address.

	MikaL
