From: Ben Greear <greearb@candelatech.com>
Subject: Re: e100 firmware in 2.6.29-rc7?
Date: Mon, 16 Mar 2009 13:20:43 -0700
Message-ID: <49BEB49B.8090602@candelatech.com>
References: <49BABF1F.9080909@candelatech.com>	
	<alpine.WNT.2.00.0903161143180.5116@jbrandeb-desk1.amr.corp.intel.com>	
	<49BEA4E6.1000206@candelatech.com>
	<1237231540.3106.9.camel@achroite>	
	<49BEB115.4050303@candelatech.com>
	<1237234322.16956.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, NetDev <netdev@vger.kernel.org>,
	dwmw2@infradead.org, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Dan Williams <dcbw@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1237234322.16956.88.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Dan Williams wrote:

>> Well, that's an annoyance.  Would it be that hard to allow modular drivers
>> to compile-in their FW as well?  It would be a nice option for
>> those of us trying to build portable pre-compiled kernels for various
>> distributions and distribution versions.
> 
> Most of those distros will have firmware loading capability though,
> right?  Every non-embedded distro (Fedora, RHEL, SUSE, Ubuntu,
> Slackware, Mandriva, Xandros, etc) has it, so if you're building kernels
> for those, there's not really a problem with dropping firmware into the
> firmware directory for that distro, right?

No, but figuring out the problem from a customer's bug report ("nothing works")
and then finding the firmware and having the customer install it will be much
worse than just having everything work like it used to.

I just see zero benefits to having external firmware
for the vast majority of end-users, and lots of downside
for at least myself.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
