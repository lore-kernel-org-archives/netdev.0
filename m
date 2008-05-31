From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] setup wake-on-lan before shutting down
Date: Fri, 30 May 2008 22:20:26 -0400
Message-ID: <4840B5EA.5060408@garzik.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518130236.GB21417@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Tobias Diedrich <ranma+kernel@tdiedrich.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemm
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54328 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753889AbYEaCUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:20:30 -0400
In-Reply-To: <20080518130236.GB21417@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:
> From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
> 
> When hibernating in 'shutdown' mode, after saving the image the suspend hook
> is not called again.
> However, if the device is in promiscous mode, wake-on-lan will not work.
> This adds a shutdown hook to setup wake-on-lan before the final shutdown.
> 
> Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

applied 2-4


