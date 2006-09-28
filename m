From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] softmac: Fix WX and association related races
Date: Thu, 28 Sep 2006 16:27:21 +0200
Message-ID: <1159453641.2648.20.camel@ux156>
References: <200609271726.34305.mb@bu3sch.de>
	 <200609271950.47430.mb@bu3sch.de> <451B4AF6.3090203@lwfinger.net>
	 <200609281455.53763.mb@bu3sch.de>
	 <1159453174.2642.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53635 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161141AbWI1O0r
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 10:26:47 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1159453174.2642.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 10:19 -0400, Dan Williams wrote:

> I'd buy that argument.  When the driver gets the deauth message,
> shouldn't it be sending an IWAP 00:00:00:00:00:00 wireless event to
> userspace?

I thought we did that since a long time now, didn't you actually develop
the initial patch?

johannes
