From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: Thu, 22 May 2003 00:59:31 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.005931.68146729.davem@redhat.com>
References: <20030521231801.GE10295@conectiva.com.br>
	<20030521.162707.88487215.davem@redhat.com>
	<20030522004718.GB13028@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@osdl.org, ncorbic@sangoma.com, dm@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030522004718.GB13028@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 21 May 2003 21:47:18 -0300

   Em Wed, May 21, 2003 at 04:27:07PM -0700, David S. Miller escreveu:
   > Note that, as I said in another email, these MOD_* calls can't just be
   > deleted, the PROCFS registry etc. have to set ->owner fields correctly
   > before this is valid.
   
   Yoshfuji-san has already done this in wanproc.c.
   
That's true.  But we need to check for other cases to make
sure they are ok.  For example, wanrouter_router_devlist.

If you really think it's fine, just resend the change and I'll
install it.
