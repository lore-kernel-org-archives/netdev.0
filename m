From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/2] Traffic control cgroups subsystem
Date: Thu, 11 Sep 2008 01:52:50 +0200
Message-ID: <20080910235250.GL20815@postel.suug.ch>
References: <Pine.LNX.4.64.0809101026190.7050@ranjit.corp.google.com> <20080910.132251.73509521.davem@davemloft.net> <166fe7950809101344l7a5e2b7pfba8b2a7c03814a1@mail.gmail.com> <20080910221206.GI20815@postel.suug.ch> <166fe7950809101637o1bf22869g4939707a35a3c93b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	akpm@linux-foundation.org, lizf@cn.fujitsu.com, menage@google.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:45704 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752297AbYIJXwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 19:52:30 -0400
Content-Disposition: inline
In-Reply-To: <166fe7950809101637o1bf22869g4939707a35a3c93b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ranjit Manomohan <ranjitm@google.com> 2008-09-10 16:37
> Could you elaborate on the failure cases? We have found this to be
> useful in practice to prevent applications from reading large amounts
> of data off the network so it would be nice if it were supported.

It works fairly well for a small number of bulk streams when no packets
need to be dropped. The results get very inaccurate for higher number
of smaller streams when packets start getting dropped. The problem is
simply that currently none of the congestion notification mechanism
work in (internet) practice.

Therefore I think that it is not worth the effort. If you think
diffrently, I will be more than glad to review code. So far I haven't
seen anything that would work on ingress.
