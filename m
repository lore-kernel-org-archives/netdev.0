From: "Eric Lemoine" <eric.lemoine@gmail.com>
Subject: tg3_close question
Date: Thu, 9 Nov 2006 14:44:10 +0100
Message-ID: <5cac192f0611090544t18a28d0do943acacb8824df80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:7778 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S965997AbWKINoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 08:44:12 -0500
Received: by ug-out-1314.google.com with SMTP id m3so218864ugc
        for <netdev@vger.kernel.org>; Thu, 09 Nov 2006 05:44:11 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

Instead of tg3_netif_stop() tg3_close() uses netif_stop_queue() to
stop xmit. This doesn't seem right to me. E.g. another CPU in tg3_tx()
could do netif_wake_queue() just after tg3_close() did
netif_stop_queue(). Isn't a bug?

Thanks,
-- 
Eric
