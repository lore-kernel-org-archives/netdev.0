From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 3 Apr 2009 13:18:54 +0200
Message-ID: <20090403111854.GA11935@one.firstfloor.org>
References: <20090402085253.GA29932@gondor.apana.org.au> <49D47F11.6070400@redhat.com> <49D5EBE1.8030200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Avi Kivity <avi@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, ghaskins@novell.com,
	anthony@codemonkey.ws, andi@firstfloor.org,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gerd Hoffmann <kraxel@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49D5EBE1.8030200@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Check shared ring status when stuffing a request.  If there are requests

That means you're bouncing cache lines all the time. Probably not a big
issue on single socket but could be on larger systems.

-Andi

