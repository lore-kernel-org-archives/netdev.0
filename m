From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] cosa -- incorrect comparison for register_netdev
Date: Fri, 10 Oct 2003 00:01:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010000158.2dc9ce78.davem@redhat.com>
References: <20031009112714.18742308.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031009112714.18742308.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Oct 2003 11:27:14 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> If register_netdev fails this driver will be in trouble because
> the return values are things like -EIO or -EEXIST, not just -1.

Applied, thanks Stephen.
