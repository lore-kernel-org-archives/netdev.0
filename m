From: Duncan Sands <duncan.sands@math.u-psud.fr>
Subject: Re: possible recursive locking in ATM layer
Date: Wed, 5 Jul 2006 12:23:33 +0200
Message-ID: <200607051223.34339.duncan.sands@math.u-psud.fr>
References: <200607041759.43064.duncan.sands@math.u-psud.fr> <1152029582.3109.70.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:27265 "EHLO smtp1-g19.free.fr")
	by vger.kernel.org with ESMTP id S964783AbWGEKzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 06:55:05 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1152029582.3109.70.camel@laptopd505.fenrus.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> ok this is a real potential deadlock in a way, it takes two locks of 2
> skbuffs without doing any kind of lock ordering; I think the following
> patch should fix it. Just sort the lock taking order by address of the
> skb.. it's not pretty but it's the best this can do in a minimally
> invasive way.

The patch is effective.  Thanks for making it!

Best wishes,

Duncan.
