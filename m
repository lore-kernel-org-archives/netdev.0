From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: NAPI of many interfaces with just an interruption source
Date: Fri, 20 Feb 2009 19:33:23 +0100
Message-ID: <b0438a630902201033l395edc7ck4a2749e239797445@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org,
	=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:22207 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752081AbZBTSd0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 13:33:26 -0500
Received: by fg-out-1718.google.com with SMTP id 16so2043356fgg.17
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 10:33:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have four interfaces that share the same interruption source (four
hdlc channels in ixp4xx that share the same rx queue... but I am
trying to do the question generic).

My first approach was to declare a napi interface for each device.
When I detected the first interrupt, I determine the correct net
interface, and schedule a poll for it.

The question is that there is no warranty that the data received in
the polling belongs to the same interface, so...

- It is correct to do like this, and just analyse the data to check to
which net interface should the data be sent.
- Or NAPI is not correct for this case and we should just use the
simple interruption mechanism?

Thanks

Miguel =C1ngel =C1lvarez
