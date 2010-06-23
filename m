From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Wed, 23 Jun 2010 08:41:07 -0400
Message-ID: <20100623124106.GA13200@infradead.org>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
 <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com>
 <4C21DFBA.2070202@linux.intel.com>
 <20100623102931.GB5242@nowhere>
 <4C21E3F8.9000405@linux.intel.com>
 <20100623113806.GD5242@nowhere>
 <4C21FF9A.2040207@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	Ian Munsie <imunsie@au1.ibm.com>, linux-kernel@vger.kernel.org,
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
	WANG Cong <amwang@redhat.
To: Andi Kleen <ak@linux.intel.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <4C21FF9A.2040207@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 23, 2010 at 02:35:38PM +0200, Andi Kleen wrote:
> >I haven't heard any complains about existing syscalls wrappers.
> 
> At least for me they always interrupt my grepping.
> 
> >
> >What kind of annotations could solve that?
> 
> If you put the annotation in a separate macro and leave the original
> prototype alone. Then C parsers could still parse it.

I personally hate the way SYSCALL_DEFINE works with passion, mostly
for the grep reason, but also because it looks horribly ugly.

But there is no reason not to be consistent here.  We already use
the wrappers for all native system calls, so leaving the compat
calls out doesn't make any sense.  And I'd cheer for anyone who
comes up with a better scheme for the native and compat wrappers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
