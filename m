From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP congestion control article
Date: Tue, 29 Jun 2004 12:44:18 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040629124418.54bfe820.davem@redhat.com>
References: <20040625123953.1d42b556.buffer@antifork.org>
	<20040625091158.2e84ed3a.davem@redhat.com>
	<20040629203418.0a844a5b.buffer@antifork.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Angelo Dell'Aera" <buffer@antifork.org>
In-Reply-To: <20040629203418.0a844a5b.buffer@antifork.org>
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 20:34:18 +0200
"Angelo Dell'Aera" <buffer@antifork.org> wrote:

> First of all I  know not too much about BITCP but  I think it's unsafe
> to enable it by default... just  like it's unsafe to enable by default
> any kind of new congestion control algorithm.

I disagree.  In Stephen Hemminger and my own usage, BICTCP even
improved performance in cases where we had mistakenly misconfigured
our systems.  That, frankly, is impressive.

Because it deals with long-fat-pipe issues as well, was another reason
we choose to enable it over westwood+.

> Another thing.  I think it's  necessary to provide some  mechanism for
> enabling  just one  of these  algorithms at  a time.

We do, you turn one on and another one off. :-)

I discussed this with Stephen the other week.  We came to the conclusion
that enabling both algorithms at the same time is valid, and we should
not put obstacles in the way to prevent people who wish to do this.
It might even be beneficial in some situations.

I agree with your analysis of Vegas, and that is why I did not enable it
by default.  It has it's own set of problems, although I like many
aspects of it.
