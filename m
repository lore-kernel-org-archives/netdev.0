From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat syscalls
Date: Wed, 23 Jun 2010 19:30:47 +0900 (JST)
Message-ID: <20100623192930.B5A9.A69D9226@jp.fujitsu.com>
References: <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, Ian Munsie <imunsie@au1.ibm.com>,
        linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
        Jason Baron <jbaron@redhat.com>,
        Frederic Weisbecker <fweisbec@gmail.com>,
        Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jeff Moyer <jmoyer@redhat.com>, David Howells <dhowells@redhat.com>,
        Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Greg Kroah-Hartman <gregkh@suse.de>,
        Dinakar Guniguntala <dino@in.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Mol
To: Andi Kleen <ak@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4C21DFBA.2070202@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

> , Ian Munsie wrote:
> > From: Ian Munsie<imunsie@au1.ibm.com>
> >
> > This patch converts numerous trivial compat syscalls through the generic
> > kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.
> 
> Why? This just makes the code look uglier and the functions harder
> to grep for.

I guess trace-syscall feature need to override COMPAT_SYSCALL_DEFINE. but
It's only guess...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
