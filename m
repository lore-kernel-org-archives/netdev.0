From: "David S. Miller" <davem@redhat.com>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Tue, 18 Nov 2003 14:22:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031118142249.045ff040.davem@redhat.com>
References: <6.0.1.1.2.20031118232152.01ae5728@tornado.reub.net>
	<20031118110139.45f2be60.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: reuben-linux@reub.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031118110139.45f2be60.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 18 Nov 2003 11:01:39 -0800
Andrew Morton <akpm@osdl.org> wrote:

> It's one for the networking guys.
> 
> The mm kernels have a patch which detects when atomic_dec_and_test
> takes an atomic_t negative - it is assumed that this is a bug so
> a warning is generated.

It is a bug especially for the backtrace cases shown here, I'll take a
look.
