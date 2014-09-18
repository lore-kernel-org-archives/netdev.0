From: Vadim Kochan <vadim4j@gmail.com>
Subject: Comments regarding patch about setting netns for wireless devices
Date: Thu, 18 Sep 2014 11:05:11 +0300
Message-ID: <CAMw6YJ+uhthY83_cBHE20FgqFWdvT5M12AbfgVC7qbyHegh78Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Emmanuel Grumbach <egrumbach@gmail.com>,
	John Linville <linville@tuxdriver.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:55466 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbaIRIFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 04:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'd like to get some feedback about the patch:
    https://patchwork.kernel.org/patch/4890451/

The idea is that currently Linux wireless device is allowed to change
the network namespace only by nl80211 API, so RTM_LINK API does
not work. So I think that it should be possible to change netns
through the RTM_LINK too as generic way to change netns,
thats why I tried to solve this in the patch.

Thanks,
