From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Resolve race condition with module unload in
 qdisc_create
Date: Mon, 16 Aug 2004 17:17:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816171708.3b3e01c4.davem@redhat.com>
References: <41214A95.2000103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41214A95.2000103@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004 02:00:21 +0200
Patrick McHardy <kaber@trash.net> wrote:

> This patch resolves the race condition with module unload
> in qdisc_create by moving try_module_get up to the first
> qdisc_lookup_ops call.

Looks good, patch applied.
