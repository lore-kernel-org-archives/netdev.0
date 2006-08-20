From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] getsockopt() early argument sanity checking
Date: Sun, 20 Aug 2006 23:12:52 +0200
Message-ID: <1156108373.23756.74.camel@laptopd505.fenrus.org>
References: <20060819234806.GB27115@1wt.eu>
	 <200608200205.20876.mb@bu3sch.de> <20060820004307.GD27115@1wt.eu>
	 <20060820.124427.74745779.davem@davemloft.net>
	 <20060820203559.GT602@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751558AbWHTVNE@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
In-Reply-To: <20060820203559.GT602@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We're not assuming they're broken. When some code is maintained by many people
> and when conventions differ between similar functions (eg: setsockopt does
> the check at top level and getsockopt in the leaves),

thats not something you want to fix in 2.4 though ;)

it may be worth considering for 2.6 of course.
