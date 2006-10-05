From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 17:32:39 +0200
Message-ID: <200610051732.39319.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de> <200610051700.31171.IvDoorn@gmail.com> <45252102.8030402@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:2531 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751063AbWJEPdd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:33:33 -0400
Received: by ug-out-1314.google.com with SMTP id o38so205409ugd
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2006 08:33:32 -0700 (PDT)
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <45252102.8030402@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> > This does not happen in rt2500usb driver, since no TSF handling is possible
> > due to a lack of TSF registers in the device.
> 
> This path would be fixed by my conversion patch of sta.timer into
> sta.work that I sent you yesterday privately. Unfortunately, I don't
> have a copy at hand ATM.

That is what I expect as well, I'll ask confirmation from the person who submitted this bug.

> What about the other timers? Can they trigger any sleeping service of
> rt2x00 drivers? Ok, waiting for a BUG is always possible... ;)

Well I currently have no time to check it, but can
config_interface handler still be called from interrupt context or has this also been fixed?

Ivo
