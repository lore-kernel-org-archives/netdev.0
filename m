From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC 2.6.10 5/22] xfrm: Attempt to offload bundled xfrm_states
 for outbound xfrms
Date: Tue, 25 Jan 2005 22:11:54 -0800
Message-ID: <20050125221154.7ee3691d.davem@davemloft.net>
References: <20041230035000.13@ori.thedillows.org>
	<20041230035000.14@ori.thedillows.org>
	<20050121152045.5c92ee05.davem@davemloft.net>
	<1106373181.3691.41.camel@ori.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Dillow <dave@thedillows.org>
In-Reply-To: <1106373181.3691.41.camel@ori.thedillows.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 22 Jan 2005 00:53:01 -0500
David Dillow <dave@thedillows.org> wrote:

> I've been reworking this area already to add the ability for the user to
> control which devices/states combinations can be offloaded, so this code
> will change. What do you think about just having the driver be
> responsible for ignoring offload requests when they don't make sense,
> like when the device is down, or in sleep mode?

That would be fine.

> BTW, xfrm_lookup() also calls stale_bundle(), which also relies on
> netif_running(), among other tests.

Good catch, hmmm... let me think about this case.
