From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH 5/6] htb: use hlist for hash lists.
Date: Thu, 3 Aug 2006 12:16:38 +0200
Message-ID: <20060803101638.GA3405@ff.dom.local>
References: <20060803093444.GA2941@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:12680 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932382AbWHCKOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 06:14:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060803093444.GA2941@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03-08-2006 11:34, Jarek Poplawski wrote:
...

> On the other hand I don't understand why it should be good
> if there could be the real priority(from tos) only by accident
> equal to the classid?

OK! I've just done one more look and understand - this 0:Y
is only possible from filter, so the first problem...

Jarek P.

