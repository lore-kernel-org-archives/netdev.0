From: Otto Sabart <osabart@redhat.com>
Subject: Performance drop on SFC interface (around 30%)
Date: Thu, 16 Jun 2016 15:23:29 +0200
Message-ID: <20160616132329.GA27108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	Bert Kenward <bkenward@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60716 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339AbcFPNXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 09:23:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello netdev,
we see a performance drop (about ~30%) on sfc driver (SFC9020) when
performing netperf TCP maerts test. It seems it started from 4.7-rc0.

Which commit/change could cause this regression? Any hints?

I opened a bugzilla [0] where you can find images with results.

[0] https://bugzilla.kernel.org/show_bug.cgi?id=120461

-- 
Ota
