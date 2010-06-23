From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
	syscalls
Date: Wed, 23 Jun 2010 12:29:34 +0200
Message-ID: <20100623102931.GB5242@nowhere>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Munsie <imunsie@au1.ibm.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Jason Baron <jbaron@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Ingo Molnar <mingo@redhat.com>,
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
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Eric Biederman <ebiederm@xmission.com>,
	Simon Kagstrom <simon.kagstrom@netinsight.net>,
	WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.org>,
	Rol
To: Andi Kleen <ak@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <4C21DFBA.2070202@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 23, 2010 at 12:19:38PM +0200, Andi Kleen wrote:
> , Ian Munsie wrote:
>> From: Ian Munsie<imunsie@au1.ibm.com>
>>
>> This patch converts numerous trivial compat syscalls through the generic
>> kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.
>
> Why? This just makes the code look uglier and the functions harder
> to grep for.


Because it makes them usable with syscall tracing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
