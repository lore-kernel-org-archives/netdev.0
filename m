From: "Kris Katterjohn" <kjak@ispwest.com>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c;kernel 2.6.14
Date: Thu, 3 Nov 2005 10:13:04 -0800
Message-ID: <cff2d7595303438db8feb9237d6c835b.kjak@ispwest.com>
Reply-To: "Kris Katterjohn" <kjak@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>, jschlst@samba.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030403AbVKCSNM@vger.kernel.org>
To: "Mitchell Blank Jr" <mitch@sfgoth.com>,
	"Patrick McHardy" <kaber@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy
> Mitchell Blank Jr wrote:
> > Well the original author presumably thought that the fast-path of
> > load_pointer() was critical enough to keep inline (since it can be run many
> > times per packet)  So they made the deliberate choice of separating it
> > into two functions - one inline, one non-inline.
> 
> Exactly. __load_pointer is only called rarely, while load_pointer is
> called whenever data needs to be read from the packet. It shouldn't
> be changed without any justification.


That's a good enough answer for me!


Thanks
