From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH 3/4] ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for davinci_mdio module
Date: Tue, 30 Oct 2012 22:35:14 +0100
Message-ID: <87y5infxt9.fsf@macbook.be.48ers.dk>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
	<1351498881-32482-5-git-send-email-hvaibhav@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <paul@pwsan.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Vaibhav Hiremath <hvaibhav@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1351498881-32482-5-git-send-email-hvaibhav@ti.com> (Vaibhav
	Hiremath's message of "Mon, 29 Oct 2012 13:51:20 +0530")
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Vaibhav" == Vaibhav Hiremath <hvaibhav@ti.com> writes:

 Vaibhav> From: Mugunthan V N <mugunthanvnm@ti.com>
 Vaibhav> This patch adds hwmod entry for davinci MDIO module,
 Vaibhav> creating parent<->child relationship between CPSW and MDIO module.

 Vaibhav> This Parent-child relation is required in order to use common resources
 Vaibhav> like, clock, but still maintaining the logical separation between them.

 Vaibhav> CPGMAC SubSystem consist of various sub-modules, like, mdio, cpdma,
 Vaibhav> cpsw, etc... These sub-modules are also used in some of Davinci
 Vaibhav> family of devices, so separate and independent platform devices &
 Vaibhav> drivers for CPSW and MDIO is implemented.
 Vaibhav> In case of AM33XX, the resources are shared and common register
 Vaibhav> bit-field is provided to control module/clock enable/disable,
 Vaibhav> makes it difficult to handle common resources from both drivers.

 Vaibhav> So the solution is, create parent<->child relationship between
 Vaibhav> CPGMAC & MDIO modules.

 Vaibhav> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
 Vaibhav> Signed-off-by: Vaibhav Hiremath <hvaibhav@ti.com>
 Vaibhav> Cc: Richard Cochran <richardcochran@gmail.com>
 Vaibhav> Cc: Paul Walmsley <paul@pwsan.com>

Acked-by: Peter Korsgaard <jacmet@sunsite.dk>

-- 
Bye, Peter Korsgaard
