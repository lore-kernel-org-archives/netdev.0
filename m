From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [RFC PATCH 06/17] phy_driver: Add and use phy_driver_[un]register_multiple()
Date: Tue, 25 Oct 2011 01:41:48 -0400
Message-ID: <CAJaTeTr2XXeq7HU1k6TU6kZCXj4ud0wUMiuA+3-2uHziK-3WmQ@mail.gmail.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-7-git-send-email-Kyle.D.Moffett@boeing.com>
 <201110201715.58441.vapier@gentoo.org> <20111025050003.GC798@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@conan.davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Daney <ddaney@caviumnetworks.com>,
	Arnaud Patard <arnaud.patard@rtp-net.org>,
	Baruch Siach <baruch@tkos.co.il>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111025050003.GC798@ponder.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 01:00, Grant Likely wrote:
> On Thu, Oct 20, 2011 at 05:15:54PM -0400, Mike Frysinger wrote:
>> On Thursday 20 October 2011 17:00:13 Kyle Moffett wrote:
>> > + =A0 return phy_driver_register_multiple(bcm63xx_drivers,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ARRAY_SIZE(bcm63xx_drivers))=
;
>>
>> if only the arm ARRAY_AND_SIZE() macro could gain traction in the wi=
der tree:
>> =A0 =A0 =A0 return phy_driver_register_multiple(ARRAY_AND_SIZE(bcm63=
xx_drivers));
>
> Propose a patch to move it from arch/arm to include/linux/kernel.h.
> This is the first I've heard of this macro, but I would probably use
> it.

i thought last time rmk suggested it, things got shot down.  but maybe
i remember wrong ... it has been a while since i proposed something
that generated bike shedding, so i'll try again.
-mike
