From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] should we care of COMPAT mode in bridge ?
Date: Mon, 06 Jun 2011 21:45:40 +0200
Message-ID: <1307389540.2642.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53448 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab1FFTpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:45:44 -0400
Received: by wwa36 with SMTP id 36so4170582wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 12:45:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While trying Alexander Holler patch, I found a 32bit brctl program was
not able to work on a 64bit kernel. So I had to switch to another
machine for my tests.

brctl addbr mybridge
->
socket(PF_FILE, SOCK_STREAM, 0)         = 3
ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)

Should we care or not ?



