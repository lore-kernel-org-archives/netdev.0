From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6 2/5]: refcount qdisc->dev
Date: Wed, 4 Aug 2004 09:36:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804093604.65748762.davem@redhat.com>
References: <410FADBC.6000904@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <410FADBC.6000904@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 Aug 2004 17:22:36 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch adds refcounting for qdisc->dev to avoid accessing freed memory
> from the __qdisc_destroy rcu-callback when the device is unregistered. 
> Without
> refcounting netdev_wait_allrefs could free the device before __qdisc_destroy
> is done.

We do need this.  Applied, thanks Patrick.
