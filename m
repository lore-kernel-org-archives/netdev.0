From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.69] wanrouter clean up MOD_*_USE_COUNT
Date: Wed, 21 May 2003 16:27:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.162707.88487215.davem@redhat.com>
References: <1053550112.2444.35.camel@ibm-c.pdx.osdl.net>
	<20030521231801.GE10295@conectiva.com.br>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@osdl.org, ncorbic@sangoma.com, dm@sangoma.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: acme@conectiva.com.br
In-Reply-To: <20030521231801.GE10295@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   Date: Wed, 21 May 2003 20:18:01 -0300
   
   Already submitted to DaveM, CCed netdev, I'll fix this later
   tonight.

Note that, as I said in another email, these MOD_* calls can't just be
deleted, the PROCFS registry etc. have to set ->owner fields correctly
before this is valid.

By just removing MOD_*(), I can load just wanrouter, open a proc file,
unload the wanrouter module, and crash.
