From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Wed, 7 Jun 2006 16:08:28 +0200
Message-ID: <20060607160828.0045e7f5@griffin.suse.cz>
References: <20060607140045.GB1936@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36230 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932111AbWFGOIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 10:08:30 -0400
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20060607140045.GB1936@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 7 Jun 2006 16:00:45 +0200, Pavel Machek wrote:
> +	zd1201_enable(zd);	/* zd1201 likes to startup shouting, interfering */
> +	zd1201_disable(zd); 	/* with all the wifis in range */

I would prefer to track it down and find out where exactly is the
problem instead of this quick hack.

 Jiri

-- 
Jiri Benc
SUSE Labs
