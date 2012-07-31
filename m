From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Tue, 31 Jul 2012 13:06:37 +0400
Message-ID: <5017A01D.5080809@parallels.com>
References: <50160EEF.6050406@parallels.com> <87pq7dh6b2.fsf@xmission.com> <1343649062.21269.23.camel@edumazet-glaptop> <87k3xlfmym.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:43900 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425Ab2GaJGn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2012 05:06:43 -0400
In-Reply-To: <87k3xlfmym.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm not seeing anything obvious in the network stack with a quick skim,
> but before we start relying on the property that interface indicies are
> not globally unique I expect an good hard look at the networking stack
> to see if any of those cases where there were problems still exist.

Just an idea -- is it worth moving the possibility to have ifindidces intersect
under CONFIG_<SOMETHING> (EXPERT/CHECKPOINT_RESTORE) to let wider audience check
the code in real-life?

> Eric
> 
> .
> 

Thanks,
Pavel
