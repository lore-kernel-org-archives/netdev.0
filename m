From: Nix <nix@esperi.org.uk>
Subject: Re: [PATCH 1/2] e1000e: Disable ASPM L1 on 82574
Date: Tue, 24 Apr 2012 12:08:09 +0100
Message-ID: <87obqh75gm.fsf@spindle.srvr.nix>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
	<1335216578-21542-2-git-send-email-bootc@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-2-git-send-email-bootc@bootc.net> (Chris Boot's
	message of "Mon, 23 Apr 2012 22:29:37 +0100")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 23 Apr 2012, Chris Boot uttered the following:

> ASPM on the 82574 causes trouble. Currently the driver disables L0s for
> this NIC but only disables L1 if the MTU is >1500. This patch simply
> causes L1 to be disabled regardless of the MTU setting.

FWIW, that existing code doesn't actually work in any case. I've been
running with an MTU of 7200 on one such NIC for some time, and L0s and
L1 are definitely enabled, even though the driver says it's turning them
off.

I'll try your patch shortly, probably tomorrow. (Now I only have to
worry about the *other* bug that's been bruited about on this list --
the one where the card locks up if its peer shuts down. It's worrying
because one of my 82574Ls has a peer that's regularly suspended... I
guess I'll try and see if I can reproduce that lockup!)

-- 
NULL && (void)

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
