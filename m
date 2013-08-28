From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing
 discipline
Date: Wed, 28 Aug 2013 10:28:35 -0700
Message-ID: <20130828102835.2cfa5d41@nehalam.linuxnetplumber.net>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
	<1377662448.8828.155.camel@edumazet-glaptop>
	<1377665870.8828.163.camel@edumazet-glaptop>
	<20130828091836.5c8285f4@nehalam.linuxnetplumber.net>
	<1377710453.8277.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:57179 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab3H1R2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 13:28:40 -0400
Received: by mail-pb0-f42.google.com with SMTP id un15so6560329pbc.29
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 10:28:39 -0700 (PDT)
In-Reply-To: <1377710453.8277.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Aug 2013 10:20:53 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-08-28 at 09:18 -0700, Stephen Hemminger wrote:
> 
> > Although your idea adds completeness, not sure if it is worth it.
> > The thing is if user is using HTB, they already are using tc
> > commands to set it up, therefore the additional script steps to choose some
> > other qdisc for the leaf nodes doesn't seem like a burden.
> > Therefore the sysctl doesn't help much and might even create more
> > confusion because there is now two places to update.
> 
> Well, I need such a facility because I cannot change HTB setup.
> 
> I can boot a new kernel, yet not really change user scripts, especially
> when tc setup is actually not a script, but a complex binary doing
> constant changes in a complex and dynamic HTB hierarchy.
> 
> 
> 

Hate to say it but maybe module parameter to htb would be an alternative
if you have to deal with that.
