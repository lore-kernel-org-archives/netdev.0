From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netem: memory leak
Date: Sun, 6 Feb 2005 22:09:14 -0800
Message-ID: <20050206220914.457727db.davem@davemloft.net>
References: <20050204231103.33325.qmail@web41510.mail.yahoo.com>
	<20050204153108.703ea71b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nistnet_user@yahoo.com, netem@lists.osdl.org, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050204153108.703ea71b@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Feb 2005 15:31:08 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Good catch.. netem needs to free skb's that are dropped due to loss
> simulation.

Applied to 2.6.x and backported to 2.4.x, thanks Stephen.
