From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] compile error in ieee80211_ioctl.c
Date: Wed, 26 Apr 2006 18:37:34 +0200
Message-ID: <20060426183734.4ac5dc6c@griffin.suse.cz>
References: <20060425211236.GC19116@tuxdriver.com>
	<20060426162946.38818.qmail@web50212.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:8650 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932462AbWDZQhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 12:37:36 -0400
To: Alex Davis <alex14641@yahoo.com>
In-Reply-To: <20060426162946.38818.qmail@web50212.mail.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Apr 2006 09:29:46 -0700 (PDT), Alex Davis wrote:
> Here is an updated patch which addresses Randy's issues. I'm currently running
> this with no problems:
> [...]
> +module_param(ieee80211_regdom, int, 0666);
>  MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");

NAK. Those parameters should not be writable yet.

Please see
http://marc.theaimsgroup.com/?l=linux-netdev&m=114565040832451&w=2 for
the correct patch (hopefully John will pull it soon).

 Jiri

-- 
Jiri Benc
SUSE Labs
