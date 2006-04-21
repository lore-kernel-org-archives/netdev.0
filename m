From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 9/10] d80211: rename master interface
Date: Fri, 21 Apr 2006 23:06:47 +0200
Message-ID: <20060421230647.34541657@griffin.suse.cz>
References: <20060421225314.048983000.midnight@suse.cz>
	<20060421205329.4059F482C0@silver.suse.cz>
	<20060421140254.65fe7d29@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42408 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932182AbWDUVGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 17:06:48 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060421140254.65fe7d29@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Apr 2006 14:02:54 -0700, Stephen Hemminger wrote:
> On Fri, 21 Apr 2006 22:53:29 +0200 (CEST)
> Jiri Benc <jbenc@suse.cz> wrote:
> > -	memcpy(mdev->name, "wlan%d", 7);
> > +	memcpy(mdev->name, "wmaster%d", 10);
> 
> Why not use strlcpy or strncpy?  and use sizeof(mdev->name) or IFNAMSIZ
> rather than hard coded 10.

Good idea :-) Will fix it, thanks.

 Jiri

-- 
Jiri Benc
SUSE Labs
