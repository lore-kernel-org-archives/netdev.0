From: Nix <nix@esperi.org.uk>
Subject: Re: e1000e interface hang on 82574L
Date: Mon, 19 Mar 2012 16:19:32 +0000
Message-ID: <87r4wova0b.fsf@spindle.srvr.nix>
References: <4EFA4024.5000909@bootc.net>
	<FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com>
	<4F048861.8070501@bootc.net> <4F12B42C.9030803@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
	<4F64CFCB.7060702@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, Chris Boot <bootc@bootc.net>,
	lkml <linux-kernel@vger.kernel.org>
To: "Wyborny\, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B6260E512E0C@ORSMSX102.amr.corp.intel.com>
	(Carolyn Wyborny's message of "Mon, 19 Mar 2012 14:59:41 +0000")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 19 Mar 2012, Carolyn Wyborny stated:

> So, at least we are clear in your situation, the ASPM needs to be
> disabled. Please let me know if there are continued problems after
> booting with pcie_aspm=off.

If you look further down in
<http://sourceforge.net/tracker/index.php?func=detail&aid=3170405&group_id=42302&atid=447449>
you'll see that I tested that, and it doesn't work :( even if it did
work, it shouldn't be needed: the driver attempts to turn off PCIe ASPM
on affected NICs, and fails, apparently because *something* turns it
back on again.

-- 
NULL && (void)

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
