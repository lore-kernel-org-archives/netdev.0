From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Possible circular locking in current wireless-dev.git
Date: Sun, 03 Sep 2006 15:11:36 -0500
Message-ID: <44FB36F8.6060605@lwfinger.net>
References: <44FB03C0.5080204@lwfinger.net> <20060903192457.GA2483@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, jkmaline@cc.hut.fi,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:33789 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932085AbWICULu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 16:11:50 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060903192457.GA2483@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Larry Finger <Larry.Finger@lwfinger.net> :
>> When booting the latest version of Linville's wireless-dev
>> and starting my BCM4306 with WPA-PSK TKIP, the I get the
>> following INFO printout that indicates a possible circular locking dependency
>> involving 80211 and wpa_supplicant.
> 
> Please try the patch below that Xerbert Xu sent a few hours
> ago on l-k and netdev:

Jamal <hadi@cyberus.ca> also suggested that patch, which does the trick.

Thanks,

Larry

-- 
VGER BF report: U 0.530972
