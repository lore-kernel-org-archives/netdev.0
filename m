From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH v2 0/2] net: enable inband link state negotiation only when
 explicitly requested
Date: Fri, 10 Jul 2015 19:38:41 +0300
Message-ID: <559FF511.5080102@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Sebastien Rannou <mxs@sbrk.org>,
	Arnaud Ebalard <arno@natisbad.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp12.mail.ru ([94.100.181.93]:39308 "EHLO smtp12.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754606AbbGJQix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2015 12:38:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Currently the link status auto-negotiation is enabled
for any SGMII link with fixed-link DT binding.
The regression was reported:
https://lkml.org/lkml/2015/7/8/865
Apparently not all HW that implements SGMII protocol, generates the
inband status for the auto-negotiation to work.
More details here:
https://lkml.org/lkml/2015/7/10/206

The following patches reverts to the old behavior by default,
which is to not enable the auto-negotiation for fixed-link.
The new DT property is added that allows to explicitly request
the auto-negotiation.

Those who were affected by the change, please send your Tested-by,
Thanks!
