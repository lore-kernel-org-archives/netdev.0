From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 2 Apr 2008 13:21:03 +0200
Message-ID: <20080402112103.GB20815@postel.suug.ch>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme> <47F13E43.2040404@trash.net> <20080331.130757.199769025.davem@davemloft.net> <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost> <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost> <47F35933.5080305@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:47201 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753073AbYDBLUn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 07:20:43 -0400
Content-Disposition: inline
In-Reply-To: <47F35933.5080305@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy <kaber@trash.net> 2008-04-02 12:00
> jamal wrote:
> >On Tue, 2008-01-04 at 13:52 +0200, Patrick McHardy wrote:
> >
> >>Isn't that what nlmsg_pid already contains?
> >
> >would work only on the case of user<->user.
> >On kernel->user it is supposed to be owned by the kernel and set to 0.
> 
> 
> No, in the case of events its supposed to be set to the pid of the
> socket that caused the event. Check out qdisc_notify() or rtmsg_ifa()
> for example.

Unfortunately in many cases the pid is also set to 0 because the
information is lost when carrying the event using the notifier
interface. Probably fixable though.
