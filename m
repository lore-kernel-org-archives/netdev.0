From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH 0/2] Interfamily IPSec BEET
Date: Mon, 4 Aug 2008 16:19:18 +0300
Message-ID: <200808041619.18790.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@wide.ad.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:41582 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbYHDNQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 09:16:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

After finally having taken the time to dig up what the problem really
is, here are a series of two patches fixing the interfamily modes of
IPSec BEET, specified in

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-08.txt

The problems were related to the the difference between ipv4 / ipv6
header lengths, as well as to the packaging of ipv4 options into the
pseudo header, when using ipv6 for transport.

Signed-off-by: Joakim Koskela <jookos@gmail.com>

---
