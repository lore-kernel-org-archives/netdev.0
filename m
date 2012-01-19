From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 0/2] igb: ptp hardware clock
Date: Thu, 19 Jan 2012 10:39:06 +0100
Message-ID: <20120119093906.GC4420@cherladcori01>
References: <cover.1325964581.git.richardcochran@gmail.com>
	<1325984559.2641.0.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <1325984559.2641.0.camel@jtkirshe-mobl>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Sat, Jan 07, 2012 at 05:02:39PM -0800, Jeff Kirsher wrote:
> On Sat, 2012-01-07 at 20:38 +0100, Richard Cochran wrote:
> > * ChangeLog
> > ** V3
> >    - Driver compiles even without CONFIG_PTP_1588_CLOCK.
> >    - Timestamping always works, even when PTP code missing or fails.
> > ** V2
> >    - Fixed wrong bit shifting in the 82576 code.
> >    - Explained the timestamp locking with a comment in the code.
> >    - Preserved the comments from the original timecompare
> > implementation.
> >    - Added an additional test within the overflow counter code to fix
> >      a race condition. Details of the problem are given in the commit
> >      message.
...
> Thanks Richard, I will add this series to my queue.

Jeff,

Please hold off with these. I adapted the driver to use
timecounter/cyclecounter as Jacob suggested, and the result is surely
nicer. I will post a V4 after I finish testing it.

Thanks,
Richard




------------------------------------------------------------------------------
Keep Your Developer Skills Current with LearnDevNow!
The most comprehensive online learning library for Microsoft developers
is just $99.99! Visual Studio, SharePoint, SQL - plus HTML5, CSS3, MVC3,
Metro Style Apps, more. Free future releases when you subscribe now!
http://p.sf.net/sfu/learndevnow-d2d
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
