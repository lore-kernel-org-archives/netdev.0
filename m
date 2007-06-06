From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/4] b44: timer power saving
Date: Wed, 6 Jun 2007 14:04:07 -0700
Message-ID: <20070606140407.73a4aa3b@oldman>
References: <20070604202536.503165465@linux-foundation.org>
	<20070604202712.223155106@linux-foundation.org>
	<200706062101.20643.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41399 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934533AbXFFVGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 17:06:05 -0400
In-Reply-To: <200706062101.20643.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I don't think we need +1, if you need to fire immediately
> (on the next tick). The timer core will always fire
> timers that are in the past immediately.

Thanks, but is it worth bothering to change it again?
