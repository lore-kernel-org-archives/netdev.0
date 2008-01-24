From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9808] New: system hung with htb
	QoS
Date: Thu, 24 Jan 2008 13:50:14 -0800
Message-ID: <20080124135014.afdbf16d.akpm@linux-foundation.org>
References: <bug-9808-10286@http.bugzilla.kernel.org/>
	<20080124061157.3512a308.akpm@linux-foundation.org>
	<36D9DB17C6DE9E40B059440DB8D95F520444FDF4@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	bilias@edu.physics.uoc.gr, auke-jan.h.kok@intel.com,
	bugme-daemon@bugzilla.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520444FDF4@orsmsx418.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> On Thu, 24 Jan 2008 12:06:58 -0800 "Brandeburg, Jesse" <jesse.brandeburg@intel.com> wrote:
> Would you be willing to try the 7.6.15 driver at e1000.sourceforge.net,
> it has many more fixes for e1000 than what is available in the in-kernel
> driver.  I just posted a patch in the "Tracker/Patches" area that
> patches 7.6.15 to support the e1000_dump code to dump rings when the tx
> hang occurs which will help us figure out a) what software did to the
> ring, b) if something is messed up in the ring which we know will hang
> the hardware

General hand-waving: if you have a debug patch which helps diagnose
rare problems when a tester hits them, please consider just putting
them straight into the mainline tree.

We can always take them out later when everything is resolved, and we
can help ourselves a lot this way. 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
