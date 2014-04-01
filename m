From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Apr 1 (netfilter)
Date: Tue, 01 Apr 2014 11:34:15 -0700
Message-ID: <533B06A7.5010900@infradead.org>
References: <20140401183907.a5127cadbe7116261096beaa@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140401183907.a5127cadbe7116261096beaa@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2014 12:39 AM, Stephen Rothwell wrote:
> Hi all,
> 
> Please do not add material intended for v3.16 to your linux-next included
> branches until after v3.15-rc1 is released.
> 
> This tree still fails (more than usual) the powerpc allyesconfig build.
> 
> Changes since 20140331:
> 
> The ia64 tree lost its build failure.
> 
> The powerpc tree still had its build failure.
> 
> The v4l-dvb tree still had its build failure so I used the version from
> next-20140328.
> 
> The audit tree gained conflicts against Linus' and the net-next trees.
> 
> Non-merge commits (relative to Linus' tree): 10933
>  9135 files changed, 457444 insertions(+), 222441 deletions(-)
> 
> ----------------------------------------------------------------------------
> 
> I have created today's linux-next tree at
> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> (patches at http://www.kernel.org/pub/linux/kernel/next/ ).  If you
> are tracking the linux-next tree using git, you should not use "git pull"
> to do so as that will try to merge the new linux-next release with the
> old one.  You should use "git fetch" as mentioned in the FAQ on the wiki
> (see below).
> 
> You can see which trees have been included by looking in the Next/Trees
> file in the source.  There are also quilt-import.log and merge.log files
> in the Next directory.  Between each merge, the tree was built with
> a ppc64_defconfig for powerpc and an allmodconfig for x86_64 and a
> multi_v7_defconfig for arm. After the final fixups (if any), it is also
> built with powerpc allnoconfig (32 and 64 bit), ppc44x_defconfig and
> allyesconfig (this fails its final link) and i386, sparc, sparc64 and arm
> defconfig.
> 
> Below is a summary of the state of the merge.
> 
> I am currently merging 213 trees (counting Linus' and 28 trees of patches
> pending for Linus' tree).
> 
> Stats about the size of the tree over time can be seen at
> http://neuling.org/linux-next-size.html .
> 
> Status of my local build tests will be at
> http://kisskb.ellerman.id.au/linux-next .  If maintainers want to give
> advice about cross compilers/configs that work, we are always open to add
> more builds.
> 
> Thanks to Randy Dunlap for doing many randconfig builds.  And to Paul
> Gortmaker for triage and bug fixes.
> 
> There is a wiki covering stuff to do with linux-next at
> http://linux.f-seidel.de/linux-next/pmwiki/ .  Thanks to Frank Seidel.

 
on x86_64:

net/netfilter/xt_connlimit.c: In function 'connlimit_mt_check':
net/netfilter/xt_connlimit.c:380:18: warning: division by zero [-Wdiv-by-zero]

Maybe just use CONNLIMIT_LOCK_SLOTS instead of ARRAY_SIZE(...).


-- 
~Randy
