From: "Ivo Van Doorn" <ivdoorn@gmail.com>
Subject: Re: [PATCH] d80211: make sleeping in hw->config possible
Date: Sun, 9 Jul 2006 23:18:19 +0200
Message-ID: <a32f33a40607091418y7ea55rd73c6982364d22b8@mail.gmail.com>
References: <200607092047.57256.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, "Jiri Benc" <jbenc@suse.cz>,
	netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:15911 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1161162AbWGIVST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jul 2006 17:18:19 -0400
Received: by py-out-1112.google.com with SMTP id 57so723214pya
        for <netdev@vger.kernel.org>; Sun, 09 Jul 2006 14:18:19 -0700 (PDT)
To: "Michael Buesch" <mb@bu3sch.de>
In-Reply-To: <200607092047.57256.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Please apply this to wireless-dev.
>
> --
>
> This patch makes sleeping in the hw->config callback possible
> by removing the only atomic caller. The atomic caller was
> a timer and is replaced by a workqueue.
>
> In general, allowing to sleep in the config callback is a
> good thing. bcm43xx must be able to sleep here, as it is
> required to lock a mutex.
> But there are other good reasons to sleep here. We might
> want to sleep for a grace period on channel switch, for example.

Excellent work.
Sleeping in hw->config is a much desired feature for rt2x00 as well,
this is especially beneficial for the USB drivers who always need sleeping.

Ivo
