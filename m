From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module nodes for
 AM33XX
Date: Fri, 2 Nov 2012 10:42:04 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293EA09122@DBDE01.ent.ti.com>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
 <1351498881-32482-6-git-send-email-hvaibhav@ti.com>
 <50914107.2090909@ti.com>
 <EB1619762EAF8B4E97A227FB77B7E0293EA08F53@DBDE01.ent.ti.com>
 <20121102085616.GB2486@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Cousson, Benoit" <b-cousson@ti.com>,
	"Hiremath, Vaibhav" <hvaibhav@ti.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paul@pwsan.com" <paul@pwsan.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20121102085616.GB2486@netboy.at.omicron.at>
Content-Language: en-US
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, November 02, 2012 2:26 PM
> To: N, Mugunthan V
> Cc: Cousson, Benoit; Hiremath, Vaibhav; netdev@vger.kernel.org;
> paul@pwsan.com; linux-arm-kernel@lists.infradead.org; linux-
> omap@vger.kernel.org
> Subject: Re: [PATCH 4/4] arm/dts: am33xx: Add CPSW and MDIO module
> nodes for AM33XX
> 
> On Fri, Nov 02, 2012 at 08:46:46AM +0000, N, Mugunthan V wrote:
> > >
> > > Do you expect to have several instance of the same IP with
> different
> > > parameters here?
> >
> > Though CPSW is a single IP in AM335X, CPSW has sub modules like
> CPDMA, ALE,
> > SLIVER, CPTS and SLAVES where is IP integrator can locate it at
> different
> > offsets. For example comparing the CPSW ip in TI814X and AM335X all
> the
> > above offsets are changed. So I have kept all these offsets in DT as
> driver
> > should not hold any SoC related informations
> 
> Did you see the two messages on this point from yesterday?

I saw those posts. The CPSW ip version changes tracks the internal IP
changes and there is no possible way to track the offset changes. For
example CPTS sub module offsets in DM814x and AM335x are different
though the CPTS version is same in both IP versions. So keeping these
offset in DT will make the same driver works directly with DT changes
for future SoC.

Regards
Mugunthan V N
