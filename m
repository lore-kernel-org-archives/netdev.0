From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] always set westwood rtt (trivial)
Date: Mon, 8 Mar 2004 12:04:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040308120449.00db3983.davem@redhat.com>
References: <20040308101726.4d08467a@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040308101726.4d08467a@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 8 Mar 2004 10:17:26 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> It is faster just to update the rtt even if we never use it.

We save a dirty cache line in the tcp_opt structure when westwood
is off.

Does it really matter?  Who knows... I'm so ambivalent about this that
I'm just not going to apply the patch for now. :-)
