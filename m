From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v2] tg3: Tx availability fix
Date: Fri, 06 Jul 2007 09:14:40 -0400
Message-ID: <1183727680.5155.12.camel@localhost>
References: <1183681399.24582.68.camel@teletran1>
	 <1183683561.24582.76.camel@teletran1>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.239]:23549 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbXGFNOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 09:14:44 -0400
Received: by wx-out-0506.google.com with SMTP id h31so181423wxd
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2007 06:14:43 -0700 (PDT)
In-Reply-To: <1183683561.24582.76.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt,

I have applied both changes (and updated the git tree) with a small
caveat on the second patch:

On Thu, 2007-05-07 at 17:59 -0700, Matt Carlson wrote:

> The last change makes sure that new xmit_win values, as assigned by the
> transmit queue wake code, will not be drastically larger than the value
> set during initialization.

I have left out the above change i.e i kept it as
dev->xmit_win = tp->tx_pending

If you dont mind lets keep it that way for now so we dont introduce any
new variables. i.e. thats how i have been testing and collecting
results. 
If you run some tests and come up with better results by using a /4 i
would be more than happy to add it back.

Thanks very much for all your efforts - Broadcom rocks.

cheers,
jamal

