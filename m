From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: Wed, 21 May 2003 21:47:18 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522004718.GB13028@conectiva.com.br>
References: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net> <20030521231801.GE10295@conectiva.com.br> <20030521.162707.88487215.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@osdl.org, ncorbic@sangoma.com, dm@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030521.162707.88487215.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, May 21, 2003 at 04:27:07PM -0700, David S. Miller escreveu:
>    From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
>    Date: Wed, 21 May 2003 20:18:01 -0300
>    
>    Already submitted to DaveM, CCed netdev, I'll fix this later
>    tonight.
> 
> Note that, as I said in another email, these MOD_* calls can't just be
> deleted, the PROCFS registry etc. have to set ->owner fields correctly
> before this is valid.

Yoshfuji-san has already done this in wanproc.c.
