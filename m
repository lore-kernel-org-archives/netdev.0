From: Yinglin Sun <yinglin.s@gmail.com>
Subject: [tcp-dsack] interface for retrieving dsack information
Date: Tue, 14 Jul 2009 20:21:58 -0400
Message-ID: <46bf9ede0907141721g5b7763b2hf2b6ec1c7a5782a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:34667 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526AbZGOAWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 20:22:00 -0400
Received: by ewy26 with SMTP id 26so3695206ewy.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 17:21:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm trying to count the number of unnecessary retransmissions for a
tcp connection. DSACK reports the receipt of duplicate segment to
sender, so I plan to count the duplicate transmissions reported by
DSACK as unnecessary retransmissions. My question is if there is a
nice interface, like tcp_info, which can be used for retrieving the
number of duplicate transmissions from DSACK? tcp_info structure
doesn't include such information.

Thanks a lot.

Yinglin
