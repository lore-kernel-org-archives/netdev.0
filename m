From: Frederik Himpe <fhimpe@telenet.be>
Subject: Re: e1000e: NIC not working, power management issue?
Date: Wed, 21 Sep 2011 22:57:23 +0200
Message-ID: <1316638644.16838.3.camel@defected>
References: <1316032260.6309.1.camel@defected>
	<CALWPMBEvwFbP-G+Ojfr_vM2riwG9vax3_3cQ1SzBR4OmdnHnsw@mail.gmail.com>
	<20110915044804.GA30817@xanadu.blop.info>
	<CALWPMBH0LSZV0yM8_24yANmn+AbscoqwiJKUnWnzGsN6hJdrhw@mail.gmail.com>
	<20110915162354.GA5935@xanadu.blop.info>
	<D38E8E86660E514AB505863C19C9287C16E92FA6@ORSMSX101.amr.corp.intel.com>
	<20110915172927.GA9854@xanadu.blop.info>
	<D38E8E86660E514AB505863C19C9287C16E93015@ORSMSX101.amr.corp.intel.com>
	<20110915175004.GA11691@xanadu.blop.info>
	<D38E8E86660E514AB505863C19C9287C16E934D4@ORSMSX101.amr.corp.intel.com>
	<20110916053808.GA4992@xanadu.blop.info>
	<alpine.WNT.2.00.1109161020490.3092@jbrandeb-mobl2.amr.corp.intel.com>
	<1316545412.19344.5.camel@defected>
	<1316598051.2182.48.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Lucas Nussbaum <lucas@lucas-nussbaum.net>, "Ronciak,
	John" <john.ronciak@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, John Ronciak <john.ronciak@gmail.com>
To: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org, netdev
	<netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1316598051.2182.48.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2011-09-21 at 02:40 -0700, Jeff Kirsher wrote:
> On Tue, 2011-09-20 at 12:03 -0700, Frederik Himpe wrote:
> > On Sun, 2011-09-18 at 18:04 +0200, Frederik Himpe wrote:
> > > On Sun, 2011-09-18 at 17:38 +0200, Frederik Himpe wrote:
> > > 
> > > > I also tried some older Debian kernels and 2.6.34-1~experimental.2 is
> > > > working fine, while 2.6.35-1~experimental.3 (and later kernels I tried)
> > > > is broken, so I guess the problem started between 2.6.34 and 2.6.35.
> > > > Maybe I'll try to bisect now...
> > > 
> > > Apparently these old kernels do not build anymore with my recent
> > > toolchain:
> > > 
> > >   AS      arch/x86/kernel/entry_64.o
> > > /tmp/ccksyA7i.s: Assembler messages:
> > > /tmp/ccksyA7i.s: Error: .size expression for do_hypervisor_callback does
> > > not evaluate to a constant
> > > 
> > > So I'm stuck here.
> > 
> > Any further thing we can do to help this problem getting fixed?
> > 
> 
> You noted that the problem started between 2.6.34 and 2.6.35, and that
> you were going to try and bisect to find the "problem" patch.  How is
> that effort coming along?

I cannot successfully build these kernels with my toolchain (see above).

> It also appears that you copied netdev and lkml on the original email,
> but they appear to have been dropped from the CC earlier on in this
> email discussion.  It sounds like it would be prudent to add lkml &
> netdev back on to the email thread with what Jesse & John have suggested
> and seen based on the information provided.  This way the power
> management maintainers are aware of the issue and potentially suggest
> other possible fix(es) that have not already been suggested.

Added these lists again.

To resume what we have found up to now: when runtime PM is activated for
the e1000e NIC, it does not wake up when a cable is plugged or when
ethtool is run. Runtime PM has to be deactivated to get the NIC working
again. Apparently this problem started between 2.6.34 and 2.6.35. 



-- 
Frederik Himpe <fhimpe@telenet.be>


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure contains a
definitive record of customers, application performance, security
threats, fraudulent activity and more. Splunk takes this data and makes
sense of it. Business sense. IT sense. Common sense.
http://p.sf.net/sfu/splunk-d2dcopy1
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
