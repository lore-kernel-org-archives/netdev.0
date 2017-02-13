From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/7] staging: rtl8712: Fix some Sparse endian messages
Date: Mon, 13 Feb 2017 11:32:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0284E4D@AcuExch.aculab.com>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
 <20170211033030.28827-2-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>
To: 'Larry Finger' <Larry.Finger@lwfinger.net>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.195]:59136 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752188AbdBMLcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 06:32:12 -0500
In-Reply-To: <20170211033030.28827-2-Larry.Finger@lwfinger.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger
> Sent: 11 February 2017 03:30
> Sparse reports the following:
> 
>   CHECK   drivers/staging/rtl8712/rtl8712_xmit.c
> drivers/staging/rtl8712/rtl8712_xmit.c:564:42: warning: cast from restricted __le32
...

I think you ought to do separate patches for the changes that are only annotations
and those that actually change the code.

The latter need a proper patch description.

	David.
