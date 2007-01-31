From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [linux-pm] [RFC] Runtime power management
	on	ipw2100
Date: Wed, 31 Jan 2007 10:27:45 +0000
Message-ID: <20070131102744.GA24424@srcf.ucam.org>
References: <20070131075249.GA22115@srcf.ucam.org>
	<1170234787.6746.22.camel@amit-laptop>
	<20070131094858.GA23842@srcf.ucam.org>
	<p731wlbphz3.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ipw2100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-pm@lists.osdl.org, Amit Kucheria <amit.kucheria@nokia.com>
To: Andi Kleen <ak@suse.de>
Return-path: <ipw2100-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <p731wlbphz3.fsf@bingen.suse.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw2100-devel>
List-Post: <mailto:ipw2100-devel@lists.sourceforge.net>
List-Help: <mailto:ipw2100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw2100-devel>,
	<mailto:ipw2100-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw2100-devel-bounces@lists.sourceforge.net
Errors-To: ipw2100-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 12:13:04PM +0100, Andi Kleen wrote:
> Matthew Garrett <mjg59@srcf.ucam.org> writes:
> > 
> > PCI seems to require a delay of 10ms when sequencing from D3 to D0, 
> > which probably isn't acceptable latency for an "up" state.
> 
> It might be if the interface has been idle for some time
> (and the delay is not busy looping of course)

Hm. How would this interact with receiving packets?

-- 
Matthew Garrett | mjg59@srcf.ucam.org

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
