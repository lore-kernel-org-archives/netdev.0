From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6]: Fix module refcount and memory leaks in classful
 qdiscs' filter destruction
Date: Wed, 24 Dec 2003 19:17:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031224191721.1d43dfd4.davem@redhat.com>
References: <3FE98B23.7040000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FE98B23.7040000@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Dec 2003 13:48:35 +0100
Patrick McHardy <kaber@trash.net> wrote:

> all classful qdiscs leak memory and module refcounts when destroying
> their filters. This patch creates a new function tcf_destroy to
> properly release all resources and makes the qdiscs use it.

Applied, thanks Patrick.
