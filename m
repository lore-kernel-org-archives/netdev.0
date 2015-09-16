From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions statistics
 via debugfs
Date: Wed, 16 Sep 2015 10:14:25 -0300
Message-ID: <20150916131424.GA2311@localhost.localdomain>
References: <20150827054004.GA2228@nanopsycho.orion>
 <20150826.230115.2076911912997875741.davem@davemloft.net>
 <20150827062704.GE2228@nanopsycho.orion>
 <20150826.233603.681080899557993733.davem@davemloft.net>
 <20150827064029.GI2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, sfeldma@gmail.com,
	netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	ogerlitz@mellanox.com, jiri@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752471AbbIPNO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 09:14:29 -0400
Content-Disposition: inline
In-Reply-To: <20150827064029.GI2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 27, 2015 at 08:40:29AM +0200, Jiri Pirko wrote:
> Thu, Aug 27, 2015 at 08:36:03AM CEST, davem@davemloft.net wrote:
> >From: Jiri Pirko <jiri@resnulli.us>
> >Date: Thu, 27 Aug 2015 08:27:04 +0200
> >
> >> I'm not saying it is not possible, it certainly is. But I think that
> >> for example rocker internals have no value to default user, he
> >> should not care and he cannot find out what is going on there
> >> without knowledge or rocker.c code. The question is, do we need some
> >> standard interface to expose random debugging data? I don't think
> >> so, I think that debugfs is exactly the tool to be used in that
> >> case.
> >
> >If it is only interesting to rocker.c maintainer, he can keep a local
> >patch he applies when he needs such a facility.
> >
> >This discussion is becomming circular.
> >
> >If it's useful, it needs a well defined interface.
> >
> >If it's not useful, it doesn't belong in the tree.
> >
> >Therefore, debugfs is useless.
> 
> Fair enough.

Late reply, sorry, but another idea is to leave the stats in place (as
they were going to be calculated even with debugfs unmounted) and (for
now at least) fetch them with systemtap, perf or something like that.
Then the stats are there for when you need them and with an interface as
flexible as it can get. Even if you happen to do a post-mortem analysis,
the info would at least be there.

  Marcelo
