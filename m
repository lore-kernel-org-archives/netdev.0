From: Rayagond K <rayagond@vayavyalabs.com>
Subject: testing and validating 64-bit addressing.
Date: Mon, 18 Nov 2013 13:27:12 +0530
Message-ID: <CAJ3bTp6pjy7PFbgAfoXoisue8xAeWA0bxxDPYY01QZN1iCX=rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36595 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111Ab3KRH5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 02:57:13 -0500
Received: by mail-wi0-f179.google.com with SMTP id fb10so3406444wid.6
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 23:57:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I have one Ethernet card which supports 64-bit DMA addressing and I
need to implement this feature and test it.

I did following,

1. Implemented 64-but addressing ie changed driver to update the
descriptor start list address and buffer address into two 32-bit reg
(hig/low)
2. Enabled 64-bit addressing in device control reg.
3. Installed the 64-bit operating system on 64-bit architecture -
Fedora 15, 64 bit os , LINUX 3.8.0 kernel, Intel dual core processor,
4GB RAM.
4. And my Ethernet card is connected to HOST via PCIX.

With the above changes in the driver and test setup I am able to test
the 64-bit addressing and following are the observation made during
testing,

1. Tx/Rx descriptor address is 33-bit and same is updated correctly in
Tx/Rx desc list address low/high reg.
2. Tx/Rx buffer address is also 33-bit and same is updated correctly
in Tx/Rx desc buffer pointer low/high reg.


But I am not able to understand following,

1. Why are we always getting 33-bit address only ?
2. Can we configure OS such that it gives 64-bit address or more than
33-bit address ?
3. In case of SG list, all buffer addresses are 33-bit, why it is like
that ? Can we get mixed pointers with different width like 33-bits,
40-bit, 64-bit etc ?



Thanks
Rayagond
