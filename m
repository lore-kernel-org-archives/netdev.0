From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.11] bonding: avoid tx balance for IGMP (alb/tlb mode)
Date: Wed, 16 Mar 2005 09:37:45 -0500
Message-ID: <20050316143743.GC18393@tuxdriver.com>
References: <20050315215128.GA18262@tuxdriver.com> <4237833E.9080809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, ctindel@users.sourceforge.net,
        fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, jgarzik@pobox.com
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <4237833E.9080809@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 04:52:14PM -0800, Rick Jones wrote:
> Is that switch behaviour "normal" or "correct?"  I know next to nothing 

As Jay Vosburgh points-out, this patch only effects ALB and TLB modes.
These are modes where the link partner is unaware of the bonded
configuration.  In effect, we are tricking the switch into behaving
the way we desire.

Since the switch is unaware of our bonded behaviour, I think it makes
sense to accomodate this quirk related to IGMP snooping.

John
-- 
John W. Linville
linville@tuxdriver.com
