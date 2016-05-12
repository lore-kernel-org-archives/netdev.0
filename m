From: Daniel Tisch <daniel@tisch.hu>
Subject: r8169 bug report
Date: Fri, 13 May 2016 00:44:21 +0200
Message-ID: <CA+mv--8o4MKQUPvx_VXnVjevJ7=PGiY=qDRS8oHp8HGo-xP9Ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from balu.1b.hu ([83.137.158.192]:34647 "EHLO balu.1b.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbcELWoa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 18:44:30 -0400
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33362)
	by balu.1b.hu with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
	(Exim 4.87)
	(envelope-from <daniel@tisch.hu>)
	id 1b0zLC-00124m-6z
	for netdev@vger.kernel.org; Fri, 13 May 2016 00:44:22 +0200
Received: by mail-lf0-f47.google.com with SMTP id y84so79855292lfc.0
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 15:44:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Devs,

I have the following system: Ubuntu 14.04.4 with the latest kernel
3.13.0-86-generic (x86_64), it has an MSI Z87-G55 motherboard with the
latest BIOS (v10.7), there is the Realtek 8111G NIC on it, which is
handled by the r8169 module by default.

I had the following issue:
1. I woke the PC with WOL magic packet successfully
2. I shut down the computer after arbitrary time
3. The system restarted a few seconds after shutdown
4. I shut down again: this time it remained down
5. The system could be awaken again by WOL

I installed r8168-dkms which seems to work perfectly for me, without
this second boot issue after WOL.

If I can help you anyhow to debug this issue, please let me know. I am
not on your lists, so please send every response directly to my
address!

Thanks,
Daniel Tisch
