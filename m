From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] replace dst_release refcount error with standard
 WARN_ON
Date: Thu, 21 Oct 2004 22:05:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021220521.5314025e.davem@davemloft.net>
References: <20041021133434.73188fae@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041021133434.73188fae@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 13:34:34 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Replace the dst count underflow bug message with a standard WARN message.
> This makes errors noticeable and also reduces the kernel text size by 600
> since we aren't doing as much to setup the printk.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Applied, thanks Stephen.
