From: Dan Williams <dcbw@redhat.com>
Subject: Re: e100 firmware in 2.6.29-rc7?
Date: Mon, 16 Mar 2009 16:12:02 -0400
Message-ID: <1237234322.16956.88.camel@localhost.localdomain>
References: <49BABF1F.9080909@candelatech.com>
	<alpine.WNT.2.00.0903161143180.5116@jbrandeb-desk1.amr.corp.intel.com>
	<49BEA4E6.1000206@candelatech.com> <1237231540.3106.9.camel@achroite>
	<49BEB115.4050303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, NetDev <netdev@vger.kernel.org>,
	dwmw2@infradead.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <49BEB115.4050303@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 2009-03-16 at 13:05 -0700, Ben Greear wrote:
> Ben Hutchings wrote:
> 
> >> The config & dmesg is attached.  Some of the options are for patches we've
> >> added, and we even have a small patch in the e100 (but have had it there
> >> for years, so probably un-related to this).  Still, I will not complain
> >> if you decide to ignore the report.
> > [...]
> > 
> > Your config has CONFIG_E100=m, but CONFIG_FIRMWARE_IN_KERNEL only
> > applies to firmware used by non-modular drivers.  The assumption is that
> > once userland is capable of loading modules it is also capable of
> > loading firmware.
> 
> Well, that's an annoyance.  Would it be that hard to allow modular drivers
> to compile-in their FW as well?  It would be a nice option for
> those of us trying to build portable pre-compiled kernels for various
> distributions and distribution versions.

Most of those distros will have firmware loading capability though,
right?  Every non-embedded distro (Fedora, RHEL, SUSE, Ubuntu,
Slackware, Mandriva, Xandros, etc) has it, so if you're building kernels
for those, there's not really a problem with dropping firmware into the
firmware directory for that distro, right?

Dan



------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
