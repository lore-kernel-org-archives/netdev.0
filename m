From: Danny <dannydaemonic@gmail.com>
Subject: Re: mm kernel oops with r8169 & named, PREEMPT
Date: Wed, 13 Oct 2004 09:05:28 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <9625752b04101309054eccbf@mail.gmail.com>
References: <9625752b041012230068619e68@mail.gmail.com>
	 <20041013072814.GA24066@electric-eye.fr.zoreil.com>
Reply-To: Danny <dannydaemonic@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269390AbUJMQFd@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org
In-Reply-To: <20041013072814.GA24066@electric-eye.fr.zoreil.com>
List-Id: netdev.vger.kernel.org

On Wed, 13 Oct 2004 09:28:14 +0200, Francois Romieu wrote:
> Try the patch below (courtesy of Jon Mason, whitespaces may be wrong) and
> see 1) if things perform better 2) if "timeout" messages appear in the
> kernel log.

The patch doesn't fix or prevent the oops.  Performance might have
been better but I did no formal tests.  There were no "timeout"
messages in the kernel log, however I only ran it with this change for
35-45 minutes.

I should mention that in the kernel log, with linux-2.6.8.1-mm4, it
complains "process `named' is using obsolete setsockopt SO_BSDCOMPAT".
 However, with the most recent, 2.6.9-rc4-mm1, it doesn't get that
far.  A "Unable to handle kernel paging request at virtual address
00017f8c" happens instead.  I'm guessing the oops is just killing
named before it gets that far.

I enabled some more debug options in the kernel and I'm getting a 2nd
oops following the first.

I wasn't sure if I should paste the huge oops here, and since the raw
dmesg also shows spin lock errors, I thought I'd just post both on the
web:
http://members.cox.net/valenzdu/oops-raw
http://members.cox.net/valenzdu/oops-processed

I ran it through ksymoops but I don't have a /proc/ksyms and when I
tried using /proc/kallsyms it gave me a format error.  I hope this is
helpful, let me know if there is anything else I can do. (CC me
please.)
