From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: Wed, 21 May 2003 20:18:01 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521231801.GE10295@conectiva.com.br>
References: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ncorbic@sangoma.com, dm@sangoma.com, "davem@redhat.com" <davem@redhat.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel McNeil <daniel@osdl.org>
Content-Disposition: inline
In-Reply-To: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 21, 2003 at 01:48:32PM -0700, Daniel McNeil escreveu:
> Here is simple patch to remove MOD_INC_USE_COUNT and
> MOD_DEC_USE_COUNT.  The wanrouter module will get a reference
> when another module uses its exported symbols.

I have patches that will conflict with this one, fixing the
namespace, i.e. device_shutdown now its a core function that ends
up having its prototype included in wanmain compilation, causing
compilation to fail.

Already submitted to DaveM, CCed netdev, I'll fix this later
tonight.

- Arnaldo
