From: Sebastien Rannou <mxs@sbrk.org>
Subject: Re: [PATCH 1/2] of_mdio: add new DT property 'link' for fixed-link
Date: Fri, 10 Jul 2015 10:46:44 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1507100940530.15010@sbrk.org>
References: <559EB0A4.5080101@list.ru> <559EB1A6.1090008@list.ru> <559EBC59.6020003@gmail.com> <559EDD0C.7020907@list.ru> <559EE45C.4040408@gmail.com> <559EEAE9.4000806@list.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2036029021-454653936-1436518004=:15010"
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sbrk.org ([91.121.93.86]:58441 "EHLO sbrk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753397AbbGJIqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 04:46:47 -0400
In-Reply-To: <559EEAE9.4000806@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2036029021-454653936-1436518004=:15010
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 10 Jul 2015, Stas Sergeev wrote:

> 10.07.2015 00:15, Florian Fainelli пишет:
> > Then, if the in-band status indication is not reliable (which really
> > should be completely understood),
> Agree!
> But this is not something I can help with.
> Sebastien Rannou reports the problem, please ask him whatever
> you see fits to get a better understanding of a problem.
> The fact that his HW does not generate the inband status, is
> _my own guess_.

Yes, I confirm that my HW does not generate an in-band status. AFAIK, it's
a PHY that aggregates 4xSGMIIs to 1xQSGMII ; the MAC side of the PHY (with
inband status) is connected to the switch through QSGMII, and in this context
we are on the media side of the PHY.

-- 
Sébastien
--2036029021-454653936-1436518004=:15010--
