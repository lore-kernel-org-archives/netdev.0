From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: roaming support for d80211 stack
Date: Thu, 7 Sep 2006 09:00:06 -0700
Message-ID: <20060907160006.GA19886@instant802.com>
References: <44FE1968.3050308@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-29.dex002.intermedia.net ([64.78.21.73]:11636 "EHLO
	dhost002-29.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932092AbWIGQAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 12:00:31 -0400
To: Mohamed Abbas <mabbas@linux.intel.com>
Content-Disposition: inline
In-Reply-To: <44FE1968.3050308@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 05, 2006 at 05:42:16PM -0700, Mohamed Abbas wrote:

> Are there any one working on roaming support for  d80211 stack?

I'm not actively working on this at the moment, but I do have plans on
doing something on this area. The current implementation uses
wpa_supplicant to take care of the roaming for both cases of
ieee80211_sta.c being used (i.e., management frames processed in kernel)
and user-space MLME (management frames in user space). The trigger for
roaming is certainly not optimal; roaming process is started only after
losing connection, but roaming itself should work.

I will be most likely working with the user space MLME code in
wpa_supplicant, i.e., there won't be much changes in the d80211 stack
side. The changes there would more likely be in the area of providing
some generic operations to help scanning and reporting current signal
strength (etc.) to use space. The main changes in roaming logic would be
wpa_supplicant.

-- 
Jouni Malinen                                            PGP id EFC895FA
