From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] bridge -- support different MTU sizes
Date: Fri, 9 Jul 2004 16:45:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709164532.22202ce2.davem@redhat.com>
References: <20040708104143.67210e39@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040708104143.67210e39@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 10:41:43 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch adds support for different size MTU's to bridging.
> It is useful for bridging Ethernet's with jumbo frames, etc.
> 
> The mtu of the bridge pseudo-device is maintained as the minimum
> of all the underlying ports.  And when forwarding a frame through
> the bridge, it will drop the frame if the outgoing port's MTU
> is less than the frame size (as per 802 standard).

Looks fine, applied.
