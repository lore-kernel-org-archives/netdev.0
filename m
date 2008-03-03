From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: unable to add esp4 sa:s via af_key (net-2.6.26)
Date: Mon, 03 Mar 2008 10:34:52 +0200
Message-ID: <47CBB82C.4090702@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:18081 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbYCCIco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 03:32:44 -0500
Received: by fg-out-1718.google.com with SMTP id e21so5275467fga.17
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 00:32:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While testing the af_key dumping patch I noticed that I'm no longer able
to add esp4 SA:s. When trying to add such a SA, esp4.c:esp_init_state()
calls esp_init_authenc(), which calls crypto_alloc_ead() and fails. I tried
it with couple of ciphers that both used to work. One such failing argument
for crypto_alloc_ead is "authenc(hmac(md5),cbc(des3_ede))". Any ideas what
is going wrong?

Cheers,
  Timo

