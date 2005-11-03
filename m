From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Merge __load_pointer() and load_pointer() in net/core/filter.c;
 kernel 2.6.14
Date: Thu, 03 Nov 2005 17:19:12 +0100
Message-ID: <436A3880.9000104@trash.net>
References: <5b1bc8f2a7f34523b323fc1b58ef4c26.kjak@ispwest.com> <20051103065809.GC27232@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Kris Katterjohn <kjak@users.sourceforge.net>,
	Herbert Xu <herbert@gondor.apana.org.au>, jschlst@samba.org,
	davem@davemloft.net, acme@ghostprotocols.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030374AbVKCQTp@vger.kernel.org>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20051103065809.GC27232@gaz.sfgoth.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr wrote:
> Kris Katterjohn wrote:
> 
>>>So I guess use my patch and take "inline" off? What do you think?
> 
> Well the original author presumably thought that the fast-path of
> load_pointer() was critical enough to keep inline (since it can be run many
> times per packet)  So they made the deliberate choice of separating it
> into two functions - one inline, one non-inline.

Exactly. __load_pointer is only called rarely, while load_pointer is
called whenever data needs to be read from the packet. It shouldn't
be changed without any justification.
