From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Sat, 12 Mar 2016 19:49:22 +0100
Message-ID: <56E464B2.5050303@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
 <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DD36F5.2000308@pengutronix.de>
 <SG2PR06MB1038DD47FAFF354C99AF2E4FC3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DE8345.50901@hartkopp.net>
 <SG2PR06MB1038B71C7921984611F72CF5C3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DEC49D.4@hartkopp.net>
 <SG2PR06MB10388F87746A1191E51B199FC3B20@SG2PR06MB1038.apcprd06.prod.outlook.com>
 <56DF0900.6090906@hartkopp.net>
 <KL1PR06MB10315B45ADA2037A5AA85A56C3B50@KL1PR06MB1031.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <KL1PR06MB10315B45ADA2037A5AA85A56C3B50@KL1PR06MB1031.apcprd06.prod.outlook.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ramesh,

On 03/11/2016 08:14 AM, Ramesh Shanmugasundaram wrote:

> As we are fixing this issue in CAN dev.c, I'll remove this check in ndo_open and set CAN_CTRLMODE_FD flag in ctrlmode & remove the flag in ctrlmode_supported in the next v3 version of the patch.

I posted a V2 version of that fix some minutes ago.
It also adds some documentation and a new variable ctrlmode_static which 
makes it clear how to specify static/fixed control modes.

Please use the new can_set_static_ctrlmode() helper as suggested in the 
changes for m_can.c.

A feedback is welcome whether this new fix fits your expectations.

> Are there any further comments on v2 patch please?

Besides the stuff I wrote above: No :-)

Best regards,
Oliver
