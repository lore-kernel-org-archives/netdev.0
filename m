From: David Kimdon <david.kimdon@devicescape.com>
Subject: d80211: RFC: divide by zero when hw->maxssi not set
Date: Fri, 17 Nov 2006 15:51:09 -0800
Message-ID: <20061117235109.GA11885@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:52408 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1753501AbWKQXvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 18:51:11 -0500
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

commit 448bf25bc9e3d70a211fdf235426472089371c43 added
ieee80211_get_wireless_stats in net/d80211/ieee80211_ioctl.c.  At
present we get a divide by zero (oops) if the low level driver does
not set the new hw->maxssi field.  Perhaps:

- reject registration of devices which do not set maxssi
- do not attempt to report link quality for drivers which do not 
  set maxssi
- other ideas? 

-David
