From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: iwlwifi no authentication with AP - Re: pull request: wireless-next
 2014-09-08
Date: Tue, 09 Sep 2014 21:46:47 +0200
Message-ID: <540F5927.7000306@hartkopp.net>
References: <20140908191630.GB29412@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:31363 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbaIITxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 15:53:11 -0400
In-Reply-To: <20140908191630.GB29412@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello John, all,

on my i7 Laptop with iwlwifi the latest net-next does not connect to my access point:

[   10.305284] iwlwifi 0000:02:00.0: L1 Enabled; Disabling L0S
[   10.312179] iwlwifi 0000:02:00.0: Radio type=0x1-0x3-0x1
[   10.524936] iwlwifi 0000:02:00.0: L1 Enabled; Disabling L0S
[   10.531762] iwlwifi 0000:02:00.0: Radio type=0x1-0x3-0x1
[   10.614189] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   17.097238] wlan0: authenticate with 84:c9:b2:d5:87:80
[   17.130120] wlan0: send auth to 84:c9:b2:d5:87:80 (try 1/3)
[   17.922281] wlan0: send auth to 84:c9:b2:d5:87:80 (try 2/3)
[   18.935272] wlan0: send auth to 84:c9:b2:d5:87:80 (try 3/3)
[   19.936236] wlan0: authentication with 84:c9:b2:d5:87:80 timed out
[   21.962337] iwlwifi 0000:02:00.0: fail to flush all tx fifo queues Q 0
[   21.962348] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 3
[   21.962413] iwl data: 00000000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
[   21.962455] iwlwifi 0000:02:00.0: FH TRBs(0) = 0x00000000
[   21.962491] iwlwifi 0000:02:00.0: FH TRBs(1) = 0x00000000
[   21.962528] iwlwifi 0000:02:00.0: FH TRBs(2) = 0x00000000
[   21.962564] iwlwifi 0000:02:00.0: FH TRBs(3) = 0x00000000
[   21.962600] iwlwifi 0000:02:00.0: FH TRBs(4) = 0x00000000
[   21.962636] iwlwifi 0000:02:00.0: FH TRBs(5) = 0x00000000
[   21.962673] iwlwifi 0000:02:00.0: FH TRBs(6) = 0x00000000
[   21.962709] iwlwifi 0000:02:00.0: FH TRBs(7) = 0x0070402f
[   21.962790] iwlwifi 0000:02:00.0: Q 0 is active and mapped to fifo 3 ra_tid 0x0000 [0,3]
[   21.962869] iwlwifi 0000:02:00.0: Q 1 is active and mapped to fifo 2 ra_tid 0x0000 [0,0]
[   21.962949] iwlwifi 0000:02:00.0: Q 2 is active and mapped to fifo 1 ra_tid 0x0000 [0,0]
[   21.963030] iwlwifi 0000:02:00.0: Q 3 is active and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963109] iwlwifi 0000:02:00.0: Q 4 is active and mapped to fifo 7 ra_tid 0x0000 [48,48]
[   21.963189] iwlwifi 0000:02:00.0: Q 5 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963270] iwlwifi 0000:02:00.0: Q 6 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963350] iwlwifi 0000:02:00.0: Q 7 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963428] iwlwifi 0000:02:00.0: Q 8 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963508] iwlwifi 0000:02:00.0: Q 9 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963588] iwlwifi 0000:02:00.0: Q 10 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963669] iwlwifi 0000:02:00.0: Q 11 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963750] iwlwifi 0000:02:00.0: Q 12 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963829] iwlwifi 0000:02:00.0: Q 13 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963909] iwlwifi 0000:02:00.0: Q 14 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.963988] iwlwifi 0000:02:00.0: Q 15 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.964069] iwlwifi 0000:02:00.0: Q 16 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.964149] iwlwifi 0000:02:00.0: Q 17 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.964228] iwlwifi 0000:02:00.0: Q 18 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   21.964308] iwlwifi 0000:02:00.0: Q 19 is inactive and mapped to fifo 0 ra_tid 0x0000 [0,0]
[   22.116816] wlan0: authenticate with xx:xx:xx:xx:xx:xx
[   22.155887] wlan0: send auth to xx:xx:xx:xx:xx:xx (try 1/3)

(..)

and again and again ...

Mainly this is the changing stuff in the following dmesg output:

[   21.962348] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 3
[   26.951325] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 6
[   34.979316] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 9
[   39.964287] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 12
[   47.984243] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 15
[   55.984240] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 18
[   60.981221] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 21
[   73.878064] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 24
[   86.342476] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 27
[   98.770854] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 30
[  111.287320] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 33
[  121.045034] iwlwifi 0000:02:00.0: Current SW read_ptr 0 write_ptr 36

02:00.0 Network controller: Intel Corporation Centrino Advanced-N 6200 (rev 35)

Any idea?

Regards,
Oliver
