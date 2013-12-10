From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v2] 6lowpan: Moving generic compression code
 into 6lowpan_iphc.c
Date: Tue, 10 Dec 2013 15:19:24 +0100
Message-ID: <20131210141923.GA32698@omega>
References: <1386576963-21764-1-git-send-email-jukka.rissanen@linux.intel.com>
 <20131209081833.GB2062@omega>
 <09E9761B-6A18-4F28-9315-DD6D44C45597@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:43285 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab3LJOTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 09:19:31 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq4so5390984wib.5
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 06:19:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <09E9761B-6A18-4F28-9315-DD6D44C45597@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 01:12:10PM +0100, Marcel Holtmann wrote:
> Hi Alexander,
> 
> > thanks for working on this! Now my acked-by is correct, sry. Didn't
> > catch the debug output at first time.
> > 
> >> Because the IEEE 802154 and Bluetooth share the IP header compression
> >> and uncompression code, the common code is moved to 6lowpan_iphc.c
> >> file.
> >> 
> >> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
> >> ---
> > 
> > Acked-by: Alexander Aring <alex.aring@gmail.com>
> 
> are you fine with us carrying these patches through bluetooth-next tree.
> 

yes.

> Dave, or do you want to merge this one into net-next and then we have wireless-next pulling that in.
> 
> I am trying to figure out on how we get this handled with the minimum of conflicts during the next merge window. And also at the same time get enough exposure via linux-next. The Bluetooth part is getting ready to be pushed into bluetooth-next.
> 
I have some pending patches for udp iphc format and a rework of the
fragmentation api. I already rebased these patches on Jukka's patch.

So you can apply this patch in bluetooth-next.
Then I will wait until bluetooth-next is merged into net-next.

Is that okay for you?

- Alex
