From: David Laight <David.Laight@ACULAB.COM>
Subject: SCTP MSG_MORE code
Date: Mon, 20 Mar 2017 17:49:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB5839@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
To: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:64944 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755833AbdCTRuj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 13:50:39 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something needs to be done with SCTP MSG_MORE before the end of the rc cycle.
The current code is definitely broken.

I objected to the last 'fix' patch because it clears the flag is a place where
I don't think it is necessary to do so - so could generate extra ethernet frames.

	David
