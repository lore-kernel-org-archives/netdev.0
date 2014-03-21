From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: i217-LM boot wreckage
Date: Fri, 21 Mar 2014 15:36:11 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de>
	<alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de>
	<2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com>
	<alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thu, 20 Mar 2014, Thomas Gleixner wrote:
> On Thu, 20 Mar 2014, Ertman, DavidX M wrote:
> > Hello Thomas,
> > 
> > Could you provide the exact kernel version and kernel config you are using?
> 
> 3.14-rc7. config attached
> 
> > Do you have Runtime Power Management enabled?
> 
> According to .config yes
> 
> > Have you tried the latest driver from sourceforge.net (3.0.4.1)?
> 
> Nope, why should I?

Now I got desperate enough to do. Doesnt work either.
  
> > From your lspci output it looks like you have a Management Engine
> > enabled platform.  Do you know what version of ME is loaded?  Have
> 
> 9.0.2.1345
> 
> Disabling ME in the BIOS does not help.
> 
> > you checked to see that you are on the latest BIOS/NVM image (looks
> > like a new one was released on March 11th for the M93z)?
> 
> Yep. Latest BIOS does not help either.

Just for extended fun: The Thinkpad L440 has the same issue.

Thanks,

	tglx

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
