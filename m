From: Samir Bellabes <sbellabes@mandriva.com>
Subject: Re: [PATCH] Network Events Connector
Date: Thu, 05 Oct 2006 03:10:02 +0200
Message-ID: <m21wpn600l.fsf@cerbere.dyndns.info>
References: <m23ba7gscl.fsf@cerbere.dyndns.info>
	<20061002090222.GA32591@2ka.mipt.ru>
	<m2r6xqg9ik.fsf@cerbere.dyndns.info>
	<20061002131345.GA18129@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samir Bellabes <sbellabes@mandriva.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 188.235.97-84.rev.gaoland.net ([84.97.235.188]:64416 "EHLO
	cerbere.dyndns.info") by vger.kernel.org with ESMTP
	id S1751299AbWJEBLE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 21:11:04 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061002131345.GA18129@2ka.mipt.ru> (Evgeniy Polyakov's message
	of "Mon, 2 Oct 2006 17:13:45 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:

> On Mon, Oct 02, 2006 at 02:57:55PM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
>> Evgeniy Polyakov <johnpol@2ka.mipt.ru> writes:
>> 
>> > On Mon, Oct 02, 2006 at 08:11:06AM +0200, Samir Bellabes (sbellabes@mandriva.com) wrote:
> You can also extend your module to be more generic and send all (or just
> requested in config) state changes for all protocols (or those checked
> in config).

Ok, so the next step now is to target all state changes for all
protocols, *but* send only the states asked dynamically from the
userspace, using the userspace-to-kernel's way of the netlink.
What do you think about that ?

>> > Btw, you could also create netlink/connector based firewall rules
>> > update, I think people with hundreds of rules in one table will bless
>> > you after that.
>> 
>> This is the real goal, using ipset - http://ipset.netfilter.org/
>> With this we can easily create a uniq rule for iptables, and then
>> add/remove port from the 'set' involve.
>
> It is not the same as create and update existing rules.
> I think hipac project uses feature of fast rules update.
> It is quite major break for existing iptables, but it should be
> eventually done...

Ok now i understand clearly your point. 
But we are a bit far from the initial idea, even if it could be really
good to do that. First, let's code the initial idea.
