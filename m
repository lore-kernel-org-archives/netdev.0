From: Gabriel Beddingfield <gabrbedd@gmail.com>
Subject: Miscalculated TCP ACK ?
Date: Mon, 22 Aug 2011 10:34:14 -0500
Message-ID: <CAPbw_hwQSXtmFSxK49jDDgF2LuG8=cu5t=ZjQ_aO7=M9fm9xeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:51831 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab1HVPeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 11:34:15 -0400
Received: by yie30 with SMTP id 30so3651407yie.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 08:34:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm having trouble with a particular server via HTTPS.  It appears
that my local linux machines are sending incorrect ACK.  However, I
don't have enough expertise to know for sure.

Using wireshark, the server sends:

    Transmission Control Protocol, Src Port: https (443), Dst Port:
36015 (36015), Seq: 27658, Ack: 827, Len: 18

Local machine replies:

    Transmission Control Protocol, Src Port: 36015 (36015), Dst Port:
https (443), Seq: 827, Ack: 27677, Len: 0

It appears to me that the ACK is off-by-one (should have been 27676).
The server replies again with retransmissions.  This is with several
kernel versions on local machines, ranging from 2.6.31 to 2.6.38.

Can anyone shed insight into what's happening?  This looks like a bug to me.

Thanks,
Gabriel
