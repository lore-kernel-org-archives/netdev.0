From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: 25 Jan 2004 14:22:19 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1075058539.1747.92.camel@jzny.localdomain>
References: <20040125152419.GA3208@penguin.localdomain>
	 <20040125164431.GA31548@louise.pinerecords.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20040125164431.GA31548@louise.pinerecords.com>
List-Id: netdev.vger.kernel.org


There has been no real good reason as to why IMQ is needed to begin
with. It may be easy to use and has been highly publized (which is
always a dangerous thing in Linux).

Maybe lets take a step back and see how people use it. How and why do
you use IMQ? Is this because you couldnt use the ingress qdisc?
Note, the abstraction to begin with is in the wrong place - it sure is
an easy and nice looking hack. So is the current ingress qdisc, but we
are laying that to rest with TC extensions.

cheers,
jamal

On Sun, 2004-01-25 at 11:44, Tomas Szepe wrote:
> On Jan-25 2004, Sun, 16:24 +0100
> Marcel Sebek <sebek64@post.cz> wrote:
> 
> > I have ported IMQ driver from 2.4 to 2.6.2-rc1.
> > Original version was from http://trash.net/~kaber/imq/.
> > ...
> 
> It would definitely be nice to see IMQ merged at last.
