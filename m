From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 1/4] b44: timer power saving
Date: Thu, 7 Jun 2007 10:37:37 +0200
Message-ID: <200706071037.37522.mb@bu3sch.de>
References: <20070604202536.503165465@linux-foundation.org> <200706062101.20643.mb@bu3sch.de> <20070606140407.73a4aa3b@oldman>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:51174
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbXFGIiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 04:38:16 -0400
In-Reply-To: <20070606140407.73a4aa3b@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 06 June 2007 23:04:07 Stephen Hemminger wrote:
> 
> > I don't think we need +1, if you need to fire immediately
> > (on the next tick). The timer core will always fire
> > timers that are in the past immediately.
> 
> Thanks, but is it worth bothering to change it again?

No, I don't think so. I just wanted to point that out.

-- 
Greetings Michael.
