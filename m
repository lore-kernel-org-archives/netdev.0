From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 1/1] net sched actions: add time filter for
 action dumping
Date: Tue, 18 Apr 2017 15:12:59 -0700
Message-ID: <20170418151259.72eaa05a@cakuba.lan>
References: <1492350973-6846-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com, jiri@resnulli.us
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:44279 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753472AbdDRWNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Apr 2017 18:13:16 -0400
In-Reply-To: <1492350973-6846-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Apr 2017 09:56:13 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This adds support for filtering based on time since last used.
> When we are dumping a large number of actions it is useful to
> have the option of filtering based on when the action was last
> used to reduce the amount of data crossing to user space.

Noob question - would it be an option to establish some form of
streaming statistic updates out of the kernel?  The notion of user
space trying to keep track of the time here seems a bit shaky.  Would
it be an option with netlink to open a socket and request specific
set of statistic to be dumped on it periodically if they changed?
I guess it would be way more code that the patch you present...
