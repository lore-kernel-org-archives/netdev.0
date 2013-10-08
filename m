From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 08 Oct 2013 15:45:08 +0200
Message-ID: <1381239908.13359.12.camel@jlt4.sipsolutions.net>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	 <1381233152.13359.10.camel@jlt4.sipsolutions.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
	 <23D74823-0DE3-4A87-9E89-310F437A328D@linaro.org>
	 (sfid-20131008_154139_954283_CE737C83)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
	"<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
	"<patches@linaro.org>" <patches@linaro.org>,
	"<linville@tuxdriver.com>" <linville@tuxdriver.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:33549 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214Ab3JHNpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:45:21 -0400
In-Reply-To: <23D74823-0DE3-4A87-9E89-310F437A328D@linaro.org> (sfid-20131008_154139_954283_CE737C83)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-08 at 15:41 +0200, Ard Biesheuvel wrote:

> Actually, as the size is always the same, it should be feasible to
> alloc a couple of request structs at init time. would one for rx and
> one for tx be sufficient? or is this code more reentrant than that?

TX can run concurrently on multiple (four) queues using the same key.

johannes
