From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH 2/2] net: dsa: register hwmon for any provided function
Date: Thu, 16 Apr 2015 18:05:39 -0400 (EDT)
Message-ID: <973411308.896485.1429221939679.JavaMail.zimbra@savoirfairelinux.com>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1429209499-2447-2-git-send-email-vivien.didelot@savoirfairelinux.com> <20150416212638.GB2587@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:63238 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbDPWFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 18:05:41 -0400
In-Reply-To: <20150416212638.GB2587@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guenter,

> >          switch (index) {
> > +        case 0: /* temp1_input */
> > +                if (drv->get_temp)
> > +                        mode |= S_IRUGO;
> 
> This should be mandatory. Sorry, I don't really understand what you are
> trying to accomplish here.
> 
> Can you give me a real world example where a chip would support setting
> a limit but not reading it ?

I have no such example. I just did not see why this couldn't be allowed
(e.g. setting only set_temp_limit and get_temp_alarm looks fine to me).
But if you say that get_temp should be mandatory, I'm OK with that.

The primary goal of this patchset was to use DEVICE_ATTR_RW to declare
temp1_max, instead of reflecting the minimal permissions needed.

Best,
-v
