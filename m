From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove dead skb_iter code
Date: Wed, 2 Mar 2005 10:20:25 -0800
Message-ID: <20050302102025.23f479f9.davem@davemloft.net>
References: <20050302101035.61786113@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050302101035.61786113@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2 Mar 2005 10:10:35 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The code iterate over skb_frags is defined but not used by any
> existing kernel code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Rusty and co.'s planned netfilter packet parsing code will use
the iterators.  Send a patch to add a comment to this effect
or something as I'm tired of folks trying to remove this code.
:-)
