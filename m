From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 25/45] staging/octeon: Use get/put_online_cpus_atomic()
 to prevent CPU offline
Date: Sun, 23 Jun 2013 12:17:25 -0700
Message-ID: <1372015045.3137.67.camel@joe-AO722>
References: <20130623133642.19094.16038.stgit@srivatsabhat.in.ibm.com>
	 <20130623134331.19094.80396.stgit@srivatsabhat.in.ibm.com>
	 <20130623181740.GB24256@kroah.com> <51C744A9.8000406@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	tglx@linutronix.de, peterz@infradead.org, tj@kernel.org,
	oleg@redhat.com, paulmck@linux.vnet.ibm.com, rusty@rustcorp.com.au,
	mingo@kernel.org, akpm@linux-foundation.org, namhyung@kernel.org,
	walken@google.com, vincent.guittot@linaro.org,
	laijs@cn.fujitsu.com, rostedt@goodmis.org,
	wangyun@linux.vnet.ibm.com, xiaoguangrong@linux.vnet.ibm.com,
	sbw@mit.edu, fweisbec@gmail.com, zhong@linux.vnet.ibm.com,
	nikunj@linux.vnet.ibm.com, linux-pm@vger.kernel.org,
	linux-arch@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, ddaney@caviumnetworks.com
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <51C744A9.8000406@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-24 at 00:25 +0530, Srivatsa S. Bhat wrote:
> On 06/23/2013 11:47 PM, Greg Kroah-Hartman wrote:
> > On Sun, Jun 23, 2013 at 07:13:33PM +0530, Srivatsa S. Bhat wrote:
[]
> >> diff --git a/drivers/staging/octeon/ethernet-rx.c b/drivers/staging/octeon/ethernet-rx.c
[]
> Honestly, I don't know. Let's CC the author of that code (David Daney).
> I wonder why get_maintainer.pl didn't generate his name for this file,
> even though the entire file is almost made up of his commits alone!

Because by default, get_maintainer looks for a matching
file entry in MAINTAINERS.  Failing that, it looks at
one year of git history.  In this case, no work has been
done on the file for quite awhile.

--git-blame can be added to the get_maintainer.pl command
line to look for % of authorship by line and commit count.

Adding --git-blame can take a long time to run, that's why
it's not on by default.  Also, very old history can give
invalid email addresses as people move around and email
addresses decay.

If you always want to find original authors, you could
use a .get_maintainer.conf file with --git-blame in it.

$ time ./scripts/get_maintainer.pl --git-blame -f drivers/staging/octeon/ethernet-tx.c
Greg Kroah-Hartman <gregkh@linuxfoundation.org> (supporter:STAGING SUBSYSTEM,commits:4/16=25%)
David Daney <ddaney@caviumnetworks.com> (authored lines:711/725=98%,commits:13/16=81%)
Ralf Baechle <ralf@linux-mips.org> (commits:11/16=69%)
Eric Dumazet <eric.dumazet@gmail.com> (commits:2/16=12%)
Andrew Morton <akpm@linux-foundation.org> (commits:1/16=6%)
devel@driverdev.osuosl.org (open list:STAGING SUBSYSTEM)
linux-kernel@vger.kernel.org (open list)

real	0m16.853s
user	0m16.088s
sys	0m0.444s
