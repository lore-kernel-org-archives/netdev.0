From: Sebastien Rannou <mxs@sbrk.org>
Subject: Re: [5/6] mvneta: implement SGMII-based in-band link state
 signaling
Date: Thu, 9 Jul 2015 11:03:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1507091040530.23853@sbrk.org>
References: <55155D9D.6070800@list.ru> <alpine.LNX.2.02.1507081757260.28659@sbrk.org> <559D5520.3030700@list.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="2036029021-485324858-1436432606=:23853"
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <559D5520.3030700@list.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--2036029021-485324858-1436432606=:23853
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Wed, 8 Jul 2015, Stas Sergeev wrote:

> What is there? A phy chip, or something else?

It's "something else", there's a phy which aggregates 4xSGMIIs to
1xQSGMII, we are on the media side here, the MAC side is connected
to the switch through QSGMII.

> Perhaps some DT property should be added to explicitly
> enable the use of the inband status...

Yes, that would be fine.

> I'll try to come up with the patch tomorrow that adds such
> property.

Thanks! I can help for testing.

-- 
Sébastien
--2036029021-485324858-1436432606=:23853--
