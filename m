From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: igb bandwidth allocation configuration
Date: Tue, 15 Sep 2009 16:27:25 +0300
Message-ID: <4AAF963D.4060708@voltaire.com>
References: <20090910081844.GA5421@verge.net.au>	<15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
	<20090915113659.GJ24194@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20090915113659.GJ24194@verge.net.au>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Simon Horman wrote:
> It seems to me that the main problem is that from a driver point of view the PF and VFs are independent. But from a hardware point of view they aren't so its not always possible for their configuration to be independent of each other. And I'm not sure what (existing) interfaces can handle that nicely.

If the rate limiter is exposed as a feature of the VF, it doesn't matter 
who really enforces it, the "VF portion" of the HW or the PF itself. I 
agree that if you have to program the PF for the rate of a specific VF, 
then its more complex. Basically, I would expect that a VF can be 
configured with <mac, vlad-id, priority, rate> such that it can be done 
where the VF NIC is spawned, host kernel or guest kernel.

> Its not clear to me what you are asking.
I'm was asking/wondering if the Intel NICs have a rate limiter (i.e one 
can program the VF such that its rate doesn't exceed XX MB/s) or a "rate 
guarantee"  (i.e one can program the VF such that its guaranteed it will 
get YY MB/s in case it wants to xmit at least this bandwidth)

Or.


------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
