From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: net 04/05: fib_rules: allow to delete local rule
Date: Tue, 1 Dec 2009 20:12:14 +0300
Message-ID: <20091201171214.GA7544@ms2.inr.ac.ru>
References: <20091130175529.7555.10132.sendpatchset@x2.localnet> <20091130175534.7555.48216.sendpatchset@x2.localnet> <1259673821.3168.35.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	robert@herjulf.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:60710 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753462AbZLARWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 12:22:03 -0500
Content-Disposition: inline
In-Reply-To: <1259673821.3168.35.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Nice. I recall there was a lot of sentiment against this back
> when - in particular from Alexey. I cant remember the details

Indeed, I refused to do this.

Sometimes, we have to determine that an address is local in a context
where we do not have information to form a proper request to rule database.
In this case we do direct lookup in fixed table, which is designated
to contain local routes. So that rule 0 was hardwired to lookup in the
same table.

Frankly, it will work provided we do not require too much of self-consistency.
Those days I could not stand this, but it is not illegal.

Alexey
