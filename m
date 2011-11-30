From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC iproute2] sch_red: TC_RED_HARDDROP
Date: Wed, 30 Nov 2011 14:36:42 -0800
Message-ID: <20111130143642.7130aa2b@nehalam.linuxnetplumber.net>
References: <1322684749.2602.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@infradead.org>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37007 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965Ab1K3Wgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 17:36:44 -0500
In-Reply-To: <1322684749.2602.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2011 21:25:49 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Hi Thomas
> 
> In 2005, TC_RED_HARDDROP kernel support was added to RED and GRED
> (commit bdc450a0bb1 [PKT_SCHED]: (G)RED: Introduce hard dropping), but
> current iproute2 doesnt have user land support.
> 
> Is there some patch waiting somewhere, or should we :
> 
> - Remove kernel support, since nobody uses it.
> 
> - Add iproute2 support.

(Almost) nobody uses RED because they can't figure it out.
According to Wikipedia, VJ says that: 
 "there are not one, but two bugs in classic RED."


But if flag is present, then Thomas should have sent a patch, might have
been lost, that was pre-patchwork days.
