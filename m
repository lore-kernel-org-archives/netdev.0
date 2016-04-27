From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 11:50:42 +0200
Message-ID: <20160427095042.GA1962@nanopsycho.orion>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35130 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbcD0Jup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 05:50:45 -0400
Received: by mail-wm0-f66.google.com with SMTP id e201so11158754wme.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 02:50:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 27, 2016 at 11:37:18AM CEST, nicolas.dichtel@6wind.com wrote:
>This patch adds the support of the 6WIND SHULTI switch. It is a software
>switch doing L2 forwarding.
>
>This first version implements the minimum needed to get the device working.
>It also implements, via switchdev and rtnetlink, bridge forwarding offload,
>including FDB static entries, FDB learning and FDB ageing.

I have to review this more closely, but at the first glance, this is
triggering a TRAMPOLINE ALERT!

Would you please share more description about this "driver". What is the
purpose, what are benefits, usecases, etc.

Thanks!
