From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: [RFC/PATCH] IMQ port to 2.6
Date: Sun, 25 Jan 2004 23:21:49 +0300
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040125202148.GA10599@usr.lcm.msu.ru>
References: <20040125152419.GA3208@penguin.localdomain> <20040125164431.GA31548@louise.pinerecords.com> <1075058539.1747.92.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1075058539.1747.92.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

On Sun, Jan 25, 2004 at 02:22:19PM -0500, jamal wrote:
> 
> There has been no real good reason as to why IMQ is needed to begin
> with. It may be easy to use and has been highly publized (which is
> always a dangerous thing in Linux).
> 
> Maybe lets take a step back and see how people use it. How and why do
> you use IMQ? Is this because you couldnt use the ingress qdisc?

Think multiple clients connected via PPP. I want to shape traffic,
so ingress is out of question. I want different clients in a same
htb class, so using qdisc on each ppp interface is out of
question. It seems to me that IMQ is the only way to achieve my goals.

> Note, the abstraction to begin with is in the wrong place - it sure is
> an easy and nice looking hack. So is the current ingress qdisc, but we
> are laying that to rest with TC extensions.
> 
> 
~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 
