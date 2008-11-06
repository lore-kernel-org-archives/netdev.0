From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 6 Nov 2008 17:59:29 +0100
Message-ID: <200811061759.29319.mb@bu3sch.de>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org> <1225970982.3619.211.camel@johannes.berg> <8bd0f97a0811060332k281ae4d1m1fee62b27d811037@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"Mike Frysinger" <vapier@gentoo.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Mike Frysinger" <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:37728 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbYKFRA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 12:00:26 -0500
In-Reply-To: <8bd0f97a0811060332k281ae4d1m1fee62b27d811037@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 06 November 2008 12:32:50 Mike Frysinger wrote:
> OK.  regarding the patch, if we drop the "&& PCI" part, i think the
> rest should get merged ... having empty menus in kconfig is annoying.
> agreed ?

We have these all over the place.
SSB_POSSIBLE is false for virtually nobody (only for some weird architectures).
The the menu will be there in almost any case.

-- 
Greetings Michael.
