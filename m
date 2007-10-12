From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-mm1 thread exit_group issue
Date: Fri, 12 Oct 2007 13:01:07 -0700
Message-ID: <20071012130107.6f1c8421.akpm@linux-foundation.org>
References: <20071011213126.cf92efb7.akpm@linux-foundation.org>
	<20071012140328.f82af8e8.kamezawa.hiroyu@jp.fujitsu.com>
	<20071011234202.2f15bb76.akpm@linux-foundation.org>
	<20071012064658.GA8181@ftp.linux.org.uk>
	<20071012001325.ba02a6f0.akpm@linux-foundation.org>
	<20071012194759.GA31733@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, kamezawa.hiroyu@jp.fujitsu.com,
	linux-kernel@vger.kernel.org, sam@ravnborg.org,
	netdev@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759241AbXJLUBs@vger.kernel.org>
In-Reply-To: <20071012194759.GA31733@Krystal>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 15:47:59 -0400
Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> I noticed a regression between 2.6.23-rc8-mm2 and 2.6.23-mm1 (with your
> hotfixes). User space threads seems to receive a ERESTART_RESTARTBLOCK
> as soon as a thread does a pthread_join on them. The previous behavior
> was to wait for them to exit by taking a futex.
> 
> I provide a toy program that shows the problem. On 2.6.23-rc8-mm2, it
> loops forever (as it should). On 2.6.23-mm1, it exits after 10 seconds.
> 
> Any idea on what may cause this problem ?
> 
> (I also provide complete ptrace -f of a correct and buggy run and my
> kernel config. Tests were done on i386.)

No idea.  But I can reproduce it here so I'll bisect it now.  Thanks
for the test case!
