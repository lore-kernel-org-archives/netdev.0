From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 2/4] pktgen: make sure that pktgen_thread_worker has
	been executed
Date: Tue, 20 May 2008 21:59:50 +0200
Message-ID: <18483.11702.257165.615708@robur.slu.se>
References: <1211277589-8565-1-git-send-email-den@openvz.org>
	<1211277589-8565-2-git-send-email-den@openvz.org>
	<18483.6334.468166.282922@robur.slu.se>
	<1211309022.7496.3.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Robert Olsson <robert.olsson@its.uu.se>,
	Ben Greear <greearb@candelatech.com>
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933560AbYETUAn@vger.kernel.org>
In-Reply-To: <1211309022.7496.3.camel@iris.sw.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Denis V. Lunev writes:

 > static int kthread(void *_create)
 > {
 >    ...
 >    if (!kthread_should_stop())
 >        pktgen_thread_worker();
 >    ...
 > }
 > 
 > and kthread_stop. If kthread_stop will be called _before_ the control
 > goes inside pktgen_thread_worker you'll OOPS.

 For some reason my tests survives here... but agree the completion syncing
 gives better control.

 Cheers
						--ro
