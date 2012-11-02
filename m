From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes
 for AM33XX
Date: Fri, 2 Nov 2012 16:19:44 +0100
Message-ID: <20121102151944.GB2900@netboy.at.omicron.at>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
 <1351498881-32482-6-git-send-email-hvaibhav@ti.com>
 <50914107.2090909@ti.com>
 <EB1619762EAF8B4E97A227FB77B7E0293EA08F53@DBDE01.ent.ti.com>
 <20121102085616.GB2486@netboy.at.omicron.at>
 <EB1619762EAF8B4E97A227FB77B7E0293EA09122@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Cousson, Benoit" <b-cousson@ti.com>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul@pwsan.com" <paul@pwsan.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: "N, Mugunthan V" <mugunthanvnm@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EB1619762EAF8B4E97A227FB77B7E0293EA09122@DBDE01.ent.ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 02, 2012 at 10:42:04AM +0000, N, Mugunthan V wrote:
> 
> I saw those posts. The CPSW ip version changes tracks the internal IP
> changes and there is no possible way to track the offset changes. For
> example CPTS sub module offsets in DM814x and AM335x are different
> though the CPTS version is same in both IP versions. So keeping these
> offset in DT will make the same driver works directly with DT changes
> for future SoC.

But the CPSW versions are different, and the offsets could be
determined that way, couldn't they?

The TRM for the DM814x does not even make the distinction among
CPSW_SS, CPSW_PORT, CPSW_CPDMA, and so on. Instead, it places all of
the registers into one space called CPSW_3G.

So I agree with Benoit. Placing all of the offsets into DT seems like
over-engineering to me, unless you know of TI's plans to release a new
SoC with the same CPSW version but different register offsets.

Thanks,
Richard
