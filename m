From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 action/policer question
Date: Wed, 17 Jun 2009 06:45:41 +0000
Message-ID: <20090617064541.GA9819@ff.dom.local>
References: <20090615111927.GA12316@ff.dom.local> <1245072728.3948.14.camel@dogo.mojatatu.com> <20090615145222.GA2767@ami.dom.local> <1245153872.4018.14.camel@dogo.mojatatu.com> <20090617061458.GA9412@ff.dom.local> <20090617062846.GA9764@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f212.google.com ([209.85.220.212]:60989 "EHLO
	mail-fx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800AbZFQGpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 02:45:45 -0400
Received: by fxm8 with SMTP id 8so61825fxm.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 23:45:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090617062846.GA9764@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 17, 2009 at 06:28:46AM +0000, Jarek Poplawski wrote:
> On Wed, Jun 17, 2009 at 06:14:58AM +0000, Jarek Poplawski wrote:
> > On Tue, Jun 16, 2009 at 08:04:32AM -0400, jamal wrote:
> > > On Mon, 2009-06-15 at 16:52 +0200, Jarek Poplawski wrote:
> > > 
> > > > I've tried debian squeeze (testing) with: iptables v1.4.3.2, iproute2
> > > > -ss090324, and action ipt -j MARK doesn't work. AFAIK debian lenny
> > > > (stable) uses 1.4.2. I've also tried debian rescue probably based on
> > > > lenny (with iptables 1.4.2), and it seemed it didn't work yet (I'll
> > > > re-check this). When you have something new I'd be glad for Cc.
> > > 
> > > I am suprised it broke again. 
> > > Lets CC the debian iproute maintainer. 
> > 
> > I confirm I can't get 'action ipt -j MARK' working on debian lenny
> > (stable) with distro's iptables/tc. I'm not able to compile tc from
> > vanilla sources properly either - configure fails 3 IPT tests. (I
> > admit I can miss setting some (undocumented?) config variables.) So,
> > with or without debian, IMHO iproute2 needs some updates for iptables
> > 1.4.2, 1.4.3, and maybe even 1.4.4 now.
> 
> OOPS! I _can_ configure it for 1.4.2 yet (so it's only about >= 1.4.3).

Btw., so 'action -j MARK' can work with iptables 1.4.2 & updated
iproute2, but I confirm Pawel's report that 'action -j LOG' doesn't
work yet.

Jarek P.
