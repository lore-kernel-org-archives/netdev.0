From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] export correct symbols when INET not enabled
Date: Wed, 30 Jul 2003 16:52:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730165209.0f5b7094.davem@redhat.com>
References: <20030730125135.6b5d1945.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030730125135.6b5d1945.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jul 2003 12:51:35 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Several symbols relating to multicast and netlink were hidden incorrectly under CONFIG_INET
> when in fact they are needed now by drivers and available even without TCP/IP.

Applied, thanks Stephen.
