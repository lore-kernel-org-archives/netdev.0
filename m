From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Tue, 22 Oct 2013 12:32:29 -0700
Message-ID: <CAGVrzcYCK3QBMgHnZ2T=wzeckX-enwJOu7DEcKHg3s=ABivLDQ@mail.gmail.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <1382469746.19269.55.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Felix Fietkau <nbd@openwrt.org>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:49454 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753537Ab3JVTdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 15:33:10 -0400
Received: by mail-pd0-f182.google.com with SMTP id q10so8225706pdj.13
        for <netdev@vger.kernel.org>; Tue, 22 Oct 2013 12:33:09 -0700 (PDT)
In-Reply-To: <1382469746.19269.55.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/10/22 Dan Williams <dcbw@redhat.com>:
> On Tue, 2013-10-22 at 11:23 -0700, Florian Fainelli wrote:
>> This patch adds an Ethernet Switch generic netlink configuration API
>> which allows for doing the required configuration of managed Ethernet
>> switches commonly found in Wireless/Cable/DSL routers in the market.
>
> "swconfig" probably means "switch config", but is there any way to
> rename this away from the "sw" prefix, since "sw" typically means
> "software" and not "switch"?

Sure, how about something like "enetsw"? I would like to avoid using
"switch" too much since this is a C reserved keyword.
-- 
Florian
