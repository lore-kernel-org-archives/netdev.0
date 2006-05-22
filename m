From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: netlink vs. debugfs (was Re: [Patch 0/6] statistics infrastructure)
Date: Mon, 22 May 2006 22:53:27 +0400
Message-ID: <20060522185327.GB31454@2ka.mipt.ru>
References: <1148054876.2974.10.camel@dyn-9-152-230-71.boeblingen.de.ibm.com> <20060519092411.6b859b51.akpm@osdl.org> <4471FE52.8090107@am.sony.com> <20060522183359.GA26551@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Tim Bird <tim.bird@am.sony.com>, Andrew Morton <akpm@osdl.org>,
	Martin Peschke <mp3@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57043 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751131AbWEVSxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 May 2006 14:53:39 -0400
To: Balbir Singh <balbir@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060522183359.GA26551@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2006 at 12:04:00AM +0530, Balbir Singh (balbir@in.ibm.com) wrote:
> Anybody else want to take a shot in comparing the two?

Netlink is always presented in the kernel, so no need to make
additional dependencies for special FS.
But number of netlink sockets is not that big, so use new one if you
create really generic mechanism, or consider using connector/gennetlink.

-- 
	Evgeniy Polyakov
