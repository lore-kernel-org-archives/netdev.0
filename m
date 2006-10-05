From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Network Events Connector
Date: Thu, 5 Oct 2006 14:29:39 +0400
Message-ID: <20061005102937.GH1015@2ka.mipt.ru>
References: <m23ba7gscl.fsf@cerbere.dyndns.info> <20061002090222.GA32591@2ka.mipt.ru> <m2r6xqg9ik.fsf@cerbere.dyndns.info> <20061002131345.GA18129@2ka.mipt.ru> <m21wpn600l.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:17553 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751615AbWJEK3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 06:29:51 -0400
To: Samir Bellabes <sbellabes@mandriva.com>
Content-Disposition: inline
In-Reply-To: <m21wpn600l.fsf@cerbere.dyndns.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 03:10:02AM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
> > You can also extend your module to be more generic and send all (or just
> > requested in config) state changes for all protocols (or those checked
> > in config).
> 
> Ok, so the next step now is to target all state changes for all
> protocols, *but* send only the states asked dynamically from the
> userspace, using the userspace-to-kernel's way of the netlink.
> What do you think about that ?

That sounds good, but as David mentioned, if there are other good
possibilities to do so, there is no need to reinvent new one (although
sometimes it is much better to reinvent the wheel, if existing one is
square).

> >> > Btw, you could also create netlink/connector based firewall rules
> >> > update, I think people with hundreds of rules in one table will bless
> >> > you after that.
> >> 
> >> This is the real goal, using ipset - http://ipset.netfilter.org/
> >> With this we can easily create a uniq rule for iptables, and then
> >> add/remove port from the 'set' involve.
> >
> > It is not the same as create and update existing rules.
> > I think hipac project uses feature of fast rules update.
> > It is quite major break for existing iptables, but it should be
> > eventually done...
> 
> Ok now i understand clearly your point. 
> But we are a bit far from the initial idea, even if it could be really
> good to do that. First, let's code the initial idea.

Agree.

-- 
	Evgeniy Polyakov
