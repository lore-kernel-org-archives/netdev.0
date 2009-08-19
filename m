From: Mike McCormack <mikem@ring3k.org>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Thu, 20 Aug 2009 07:05:03 +0900
Message-ID: <392fb48f0908191505v47f99d1cvef18d40bcf4c08d1@mail.gmail.com>
References: <4A65EC3F.4050400@gibraltar.at>
	 <200908190902.02854.rene.mayrhofer@gibraltar.at>
	 <392fb48f0908190800j508456d6h9c520e82bc7f51e0@mail.gmail.com>
	 <200908192307.22112.rene.mayrhofer@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:6200 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbZHSWFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 18:05:06 -0400
Received: by fg-out-1718.google.com with SMTP id e21so1141204fga.17
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 15:05:06 -0700 (PDT)
In-Reply-To: <200908192307.22112.rene.mayrhofer@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/8/20 Rene Mayrhofer <rene.mayrhofer@gibraltar.at>:

> Pulling the latest sky2.c and sky2.h from net-next-2.6 and applying the patch
> rids me of the oops - it is unreproducible right now. However, a networking
> restart (i.e. all interfaces attached to sky2) leaves the devices in a state
> where they no longer receive any network packets (at least nothing visible in
> tcpdump). In this state, rmmod sky2 / modprobe sky2 gives:

After you've got it into that state, does "rmmod sky2; modprobe sky2"
change anything?

thanks,

Mike
