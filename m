From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next v2] 6lowpan: Moving generic compression code into 6lowpan_iphc.c
Date: Tue, 10 Dec 2013 13:12:10 +0100
Message-ID: <09E9761B-6A18-4F28-9315-DD6D44C45597@holtmann.org>
References: <1386576963-21764-1-git-send-email-jukka.rissanen@linux.intel.com> <20131209081833.GB2062@omega>
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jukka Rissanen <jukka.rissanen@linux.intel.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57971 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab3LJMMY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:12:24 -0500
In-Reply-To: <20131209081833.GB2062@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

> thanks for working on this! Now my acked-by is correct, sry. Didn't
> catch the debug output at first time.
> 
>> Because the IEEE 802154 and Bluetooth share the IP header compression
>> and uncompression code, the common code is moved to 6lowpan_iphc.c
>> file.
>> 
>> Signed-off-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>
>> ---
> 
> Acked-by: Alexander Aring <alex.aring@gmail.com>

are you fine with us carrying these patches through bluetooth-next tree.

Dave, or do you want to merge this one into net-next and then we have wireless-next pulling that in.

I am trying to figure out on how we get this handled with the minimum of conflicts during the next merge window. And also at the same time get enough exposure via linux-next. The Bluetooth part is getting ready to be pushed into bluetooth-next.

Regards

Marcel
