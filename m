From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Sat, 3 Dec 2005 23:25:54 +0300
Message-ID: <200512032325.54335.a1426z@gawab.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4391E4FC.1040200@candelatech.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Al Boldi wrote:
> > Here specifically, ip/ifconfig is implemented upside-down requiring a
> > link/dev to exist for an address to be defined, in effect containing
> > layer 3 inside layer 2, when an address should be allowed to be defined
> > w/o a link/dev much like an app is allowed to be defined w/o an address.
>
> You can add multiple virtual IP addresses to physical interfaces.  It
> makes no sense to have an IP without any association to an interface
> in my opinion.  Often, when you have multiple interfaces, you most
> definately want different IPs associated specifically with particular
> interfaces. Think about redundant paths, routers, firewalls, and such.

This proposal does not reduce the current features, but instead attempts to 
remove certain dependencies to aid scalability, usability, and flexibility.

Can you explain why these dependencies are necessary?

> If you do see a benefit to your proposal, please describe how you would
> use it, and why you cannot do this thing with today's code.

Does not my previous post answer this question?

> Philosophical musings about the 'proper' way to do things without concrete
> examples is unlikely to get you very far :)

I am only trying to be honest about it; no philosophical musings meant.

Thanks!

--
Al

