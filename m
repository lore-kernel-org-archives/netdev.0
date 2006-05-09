From: "Ian Brown" <ianbrn@gmail.com>
Subject: Scanning in ieee80211 softmac layer and setting essid (newbie)
Date: Tue, 9 May 2006 16:38:04 +0300
Message-ID: <d0383f90605090638u3ca7a5c0je1a4ce8bc3dc696e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:30092 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932511AbWEINiF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 09:38:05 -0400
Received: by ug-out-1314.google.com with SMTP id y2so1914122uge
        for <netdev@vger.kernel.org>; Tue, 09 May 2006 06:38:04 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
I see that setting the essid of a wireless card
(by iwconfig eth1 essid homenet)
triggers scanning;
namely , it calls ieee80211softmac_assoc_work() method which in
turn calls ieee80211softmac_start_scan().

I use zd1211 driver which works with the softmac layer
of the last git kernel.

I saw that this scanning call occurs wheter the card is down
or up (namely, ifconfig eth1 up was called).

Only in the first case (card is down) ,it only says:
Associate: Scanning for networks first.
SoftMAC: Associate: failed to initiate scan. Is device up?

and when card is up it says:

SoftMAC: Associate: Scanning for networks first.
SoftMAC: Start scanning with channel: 1
SoftMAC: Scanning 13 channels
SoftMAC: Scanning finished

several times.

My question is : why is this scanning needed when set essid is called?
and why is the repeatition?

I am a little newbie in this...

Regards,
IB
