From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] Make LLC2 compile with PROC_FS=n
Date: Mon, 20 Oct 2003 04:44:28 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020074428.GA26494@conectiva.com.br>
References: <Pine.GSO.4.58.0310171452540.13905@blinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rddunlap@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noah J. Misch" <noah@caltech.edu>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.58.0310171452540.13905@blinky>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Sun, Oct 19, 2003 at 10:03:52PM -0700, Noah J. Misch escreveu:
> Hello Arnaldo,
> 
> This patch allows the LLC2 code to link properly when CONFIG_PROC_FS=n.  The
> problem was that the Makefile only built llc_proc.c when PROC_FS=y/m, but
> af_llc.c called functions in that file in all cases.  The log details how I
> fixed this.
> 
> I think this is the best fix, but of course there are a number of less intrusive
> fixes, including (I think) one as simple as making llc_proc.c always compile.
> This one does apply cleanly to linux-2.5 BK as of 0400 UTC 10/20/2003 and passes
> allyesconfig and (allyesconfig - PROC_FS) compiles on i386.
> 
> Please let me know if I should supply you with further information.

I'm OK with this patch.

- Arnaldo
