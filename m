From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [net-next:master 98/98] drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34:
 sparse: cast to restricted __be16
Date: Fri, 30 Nov 2012 17:19:05 -0500
Message-ID: <50B930D9.9040209@myri.com>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com> <50B92A6D.8000600@myri.com> <20121130220228.GA22050@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christopher Li <sparse@chrisli.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Fengguang Wu <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:44362 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838Ab2K3WTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 17:19:09 -0500
Received: by mail-ye0-f174.google.com with SMTP id m6so155897yen.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 14:19:08 -0800 (PST)
In-Reply-To: <20121130220228.GA22050@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks guys.

In this case, it found a real typo (use of ntohs() rather than htons()).
If it would not have been for this tool making me stare at it, I never
would have seen this.

I need audit the rest of the warnings in the driver..

Sorry for the noise & thanks for this service!

Drew
