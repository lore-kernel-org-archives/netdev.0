From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 10326] New: inconsistent lock state in
	net_rx_action
Date: Thu, 27 Mar 2008 13:49:28 +0100
Message-ID: <20080327124928.GE2845@ami.dom.local>
References: <bug-10326-10286@http.bugzilla.kernel.org/> <20080325134320.21525479.akpm@linux-foundation.org> <47EAD8A5.3070806@gmail.com> <20080326171403.ad186037.akpm@linux-foundation.org> <20080327085542.GA2778@ami.dom.local> <20080327021812.601776b8.akpm@linux-foundation.org> <1206615379.8514.502.camel@twins> <20080327122255.GC2845@ami.dom.local> <1206621014.8514.563.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, marcus@better.se,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:35017 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbYC0Mni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:43:38 -0400
Received: by ug-out-1314.google.com with SMTP id z38so333832ugc.16
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 05:43:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1206621014.8514.563.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2008 at 01:30:14PM +0100, Peter Zijlstra wrote:
...
> My guess is that it is a race between polling the device and irq pushing
> the packet. That is, normally the IRQ handler wins and netpoll doesn't
> have anything to do and it doesn't traverse this code path.
> 
> (although I must admit to being a little out of my depth here)

Probably you're right but there were really a lot of testing and
stressing netconsole for misterious lockups for quite a long time
with this new napi, so it's hard to believe this was hidden so
well...

Jarek P.
