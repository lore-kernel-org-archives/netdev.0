From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Huaei E3131 - status
Date: Wed, 3 Jul 2013 09:11:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1307030908090.13789@eeeadesso>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> <87wqp9xja5.fsf@nemi.mork.no> <alpine.LNX.2.02.1307021855270.19053@eeeadesso> <alpine.LNX.2.02.1307022202570.26010@eeeadesso> <alpine.LNX.2.02.1307022207060.26010@eeeadesso>
 <alpine.LNX.2.02.1307022210470.26010@eeeadesso> <alpine.LNX.2.02.1307022213380.26010@eeeadesso> <alpine.LNX.2.02.1307030836270.12831@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:57283 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3GCHK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 03:10:59 -0400
Received: by mail-wi0-f175.google.com with SMTP id m6so4871634wiv.2
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 00:10:58 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.02.1307030836270.12831@eeeadesso>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok ... As Bjorn stated, cdc-wdm is handling the notifications now - or, better: 
is not handling them, as it is not made to do these things! The connection 
stays up and the character device seems to work properly. Obviously cdc-wdm 
notices me about one single unknown notifications.
We're ignoring all the notifications from the NCM erspective, but all works 
because the device probably doesn't rely on them so much.

Aniway - now I'm conscious about why it works. Now it's time to improve the 
situation of the driver, and might be the api. Waiting for suggestions and 
injuries! :)

thank you everybody for the help...
