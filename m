From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: RCU hang on 4.2-rc5
Date: Sat, 8 Aug 2015 12:00:28 +0200
Message-ID: <20150808100028.GA14897@sesse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:46814 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932237AbbHHKAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 06:00:35 -0400
Received: from pannekake.samfundet.no ([2001:67c:29f4::50] ident=unknown)
	by cassarossa.samfundet.no with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <sesse@samfundet.no>)
	id 1ZO0vV-0008AE-PQ
	for netdev@vger.kernel.org; Sat, 08 Aug 2015 12:00:32 +0200
Received: from sesse by pannekake.samfundet.no with local (Exim 4.84)
	(envelope-from <sesse@samfundet.no>)
	id 1ZO0vU-00051P-PY
	for netdev@vger.kernel.org; Sat, 08 Aug 2015 12:00:28 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have an issue with 4.2-rc5 where my machine hangs approximately once a day
with RCU problems. I initially didn't think it was networking related, but
the it seems to be (weakly) correlated with network activity, and there was
IPv6 stuff in one of the backtraces, so I've reassigned to the networking
component. However, I'm not sure if that generates an email to netdev. Could
anyone please have a look?

  https://bugzilla.kernel.org/show_bug.cgi?id=102291

/* Steinar */
-- 
Homepage: http://www.sesse.net/
