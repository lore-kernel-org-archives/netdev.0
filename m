From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Wed, 23 Jun 2010 12:37:44 +0200
Message-ID: <4C21E3F8.9000405@linux.intel.com>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com> <20100623102931.GB5242@nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
 Oleg Nesterov <oleg@redhat.com>,
 Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>,
 Greg Kroah-Hartman <gregkh@suse.de>,
 Dinakar Guniguntala <dino@in.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Eric Biederman <ebiederm@xmission.com>,
 Simon Kagstrom <simon.kagstrom@netinsight.net>,
 WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.o
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20100623102931.GB5242@nowhere>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

, Frederic Weisbecker wrote:
> On Wed, Jun 23, 2010 at 12:19:38PM +0200, Andi Kleen wrote:
>> , Ian Munsie wrote:
>>> From: Ian Munsie<imunsie@au1.ibm.com>
>>>
>>> This patch converts numerous trivial compat syscalls through the generic
>>> kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.
>>
>> Why? This just makes the code look uglier and the functions harder
>> to grep for.
>
>
> Because it makes them usable with syscall tracing.

Ok that information is missing in the changelog then.

Also I hope the uglification<->usefullness factor is really worth it.
The patch is certainly no slouch on the uglification side.

It also has maintenance costs, e.g. I doubt ctags and cscope
will be able to deal with these kinds of macros, so it has a
high cost for everyone using these tools. For those
it would be actually better if you used separate annotation
that does not confuse standard C parsers.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
