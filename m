From: Stefano Babic <stefano.babic@babic.homelinux.org>
Subject: Re: [RFC PATCH v3 0/8] CAIF Protocol Stack
Date: Wed, 02 Dec 2009 18:02:40 +0100
Message-ID: <4B169DB0.6010307@babic.homelinux.org>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpout09.attiva.biz ([85.37.16.7]:8033 "EHLO
	smtpout09.attiva.biz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbZLBRRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 12:17:52 -0500
In-Reply-To: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sjur.brandeland@stericsson.com wrote:
> General:
> * Sockets has replaced the character device implementation,
>   when accessing the modem. AT channels has to open sockets.

Hi Sjur,

I would like to test your patches with real hardware (based on an ARM
processor), as I did last time before sending my comments.
I think it should easier if in the Documentation there is an example to
explain how to setup a connection, for example with AT protocol. I tried
and I get "Specified PHY type does not exists", probably because I have
not well understood the parameters.

There are some errors in the MAN page documentation (patch #7) and the
example reported does not compile (for example, CAIFSO_CHANNEL should be
CAIF_CHANNEL_OPT, and so on).

Can you provide an example for the user space to setup a connection ?

> Please check what you think of the asserts in this release and get back to be!

Yes, I will do it.

Best Regards,
Stefano

-- 
stefano <stefano.babic@babic.homelinux.org>
GPG Key: 0x55814DDE
Fingerprint 4E85 2A66 4CBA 497A 2A7B D3BF 5973 F216 5581 4DDE
