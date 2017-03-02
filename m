From: Zaboj Campula <zaboj.campula@post.cz>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Thu, 02 Mar 2017 19:51:28 +0000
Message-ID: <1488484288.5717.1.camel@post.cz>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
         <20170225173927.GA2479@nanopsycho> <1488054142.3856.15.camel@post.cz>
         <20170226075633.GA1788@nanopsycho> <1488117614.1903.2.camel@post.cz>
         <20170226144610.GB2071@nanopsycho.orion> <20170227173825.39e00c61@griffin>
         <1488312457.2131.2.camel@post.cz> <20170301112228.713bd4d5@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf2.seznam.cz ([77.75.76.123]:54817 "EHLO mxf2.seznam.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750779AbdCBUUR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 15:20:17 -0500
In-Reply-To: <20170301112228.713bd4d5@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-03-01 at 11:22 +0100, Jiri Benc wrote:
> On Tue, 28 Feb 2017 20:07:37 +0000, Zaboj Campula wrote:
> > Well it is impossible to draw a simple tree showing the configuration
> > exactly with all details. May be it is too ambitious to draw a tree
> > at all.
> 
> I tried that and failed. I didn't want to have something that would
> work only "somehow" as that would create confusion instead of helping.

OK, I give up. My patch was naive and I deleted it.
Nevertheless I still think it would be useful to show network
interfaces dependencies in a pure text format.


> Consider the very simple case of an interface with two vlan interfaces
> and both of them in a bridge.
> 
>          vlan0
>       /        \
> eth0             br0
>       \        /
>          vlan1
> 
> You can't represent this in a tree view. And this is just a very simple
> example, in reality it tends to be much more complex.

Perhaps something like that:
eth0
    vlan0
        br0
    vlan1
        br0
