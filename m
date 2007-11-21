From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
Date: Wed, 21 Nov 2007 10:15:30 -0500
Message-ID: <1195658130.4437.17.camel@localhost>
References: <20071121.191840.07671434.takano@axe-inc.co.jp>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	t.kudoh@aist.go.jp
To: Ryousei Takano <takano-ryousei@aist.go.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:49136 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546AbXKUPPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 10:15:44 -0500
Received: by py-out-1112.google.com with SMTP id u77so7253916pyb
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 07:15:35 -0800 (PST)
In-Reply-To: <20071121.191840.07671434.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-21-11 at 19:18 +0900, Ryousei Takano wrote:
> This patch includes the PSPacer (Precise Software Pacer) qdisc
> module, which achieves precise transmission bandwidth control.
> You can find more information at the project web page
> (http://www.gridmpi.org/gridtcp.jsp).

Good stuff.
I have not read your paper - There are NICs out there (chelsio comes to
mind) which claim to do pacing and have shown impressive numbers with
TCP. Is your approach similar? Are there patents involved by some of
these hardware vendors? (It would not be suprising if they exist).

The advantage with NICs is they have very good control of the timing
(clock granularity being extremely important in cases like this) - what
were your measurements based on i.e what clock source did you use on
Linux?
Also, the idea of using a PAUSE frame to add gaps is interesting, but
you should note that in linux a qdisc may be attached to any network
device and this for example maybe a PPP device etc. What would you use
for gaps in that case? 
I apologize if the answers are in your papers - i just glossed over.

cheers,
jamal 

