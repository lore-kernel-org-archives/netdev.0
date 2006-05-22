From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Was change to ip_push_pending_frames intended to break
	udp	(more specifically, WCCP?)
Date: Mon, 22 May 2006 22:11:33 +0100
Message-ID: <1148332293.17376.114.camel@localhost.localdomain>
References: <20060520191153.GV3776@stingr.net>
	 <20060520140434.2139c31b.akpm@osdl.org>
	 <1148322152.15322.299.camel@galen.zko.hp.com>  <4472078D.8010706@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Paul P Komkoff Jr <i@stingr.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:39586 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1750754AbWEVU57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 16:57:59 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4472078D.8010706@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Llu, 2006-05-22 at 11:48 -0700, Rick Jones wrote:
> ID of zero again?  I thought that went away years ago?  Anyway, given 
> the number of "helpful" devices out there willing to clear the DF bit, 
> fragment and forward, perhaps always setting the IP ID to 0, even if DF 
> is set, isn't such a good idea?

Any device that clears DF is so terminally broken that you've already
lost the battle the moment you bought it. 

Alan

