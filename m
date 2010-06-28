From: James Courtier-Dutton <james.dutton@gmail.com>
Subject: b44: Reset due to FIFO overflow.
Date: Mon, 28 Jun 2010 08:41:57 +0100
Message-ID: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50394 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab0F1Hl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 03:41:59 -0400
Received: by fxm14 with SMTP id 14so408111fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 00:41:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Reference:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/279102

I can see this bug and can reproduce it 100% on demand.
The problem seems to be that when the b44 has a incoming FIFO buffer
overflow, it resets the entire card, dis-associates with the access
point and therefore takes some time before it can pass traffic again.
Can anyone point me to some code that would just recover the FIFO
instead of reset the entire card?

I am a kernel developer, but I don't have any data sheets on this card
so was hoping someone with more knowledge of its workings, could help
me.

I can then test it, and see if it is a good fix or not.

Kind Regards

James
