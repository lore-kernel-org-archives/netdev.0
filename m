From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Sat, 2 Feb 2008 12:56:08 +0200 (EET)
Message-ID: <Pine.LNX.4.58.0802021224460.3483@u.domain.uli>
References: <20080127232018.GA2856@ami.dom.local> <Pine.LNX.4.58.0801290139450.3181@u.domain.uli>
 <20080129084915.GA1624@ff.dom.local> <20080129091030.GB1624@ff.dom.local>
 <20080129095245.GA2570@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:48942 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763492AbYBBKzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 05:55:20 -0500
In-Reply-To: <20080129095245.GA2570@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 29 Jan 2008, Jarek Poplawski wrote:

> ...On the other hand, I wonder how bad would be switching these two
> to avoid this error? After all "replace" with this "add or change"
> meaning looks quite permissive, and after all it was used before with
> no such errors, so, even if correct, it could still break some
> scripts...

	Agreed, what could break are scripts that add 2 equal 
alternative routes and checking for errors. BTW, I tried to add
more information and that is what I have finally:

http://www.ssi.bg/~ja/fib.txt

Regards

--
Julian Anastasov <ja@ssi.bg>
