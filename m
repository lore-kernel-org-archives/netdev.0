From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH 1/1] driver: net: smsc911x: set NOCARRIER flag in driver initialization
Date: Tue, 3 Jun 2014 19:45:39 +0530
Message-ID: <CAHPKR9+H1gmJBqtO-4c7YBQrx+xbLenzWE6sky9Pq7=yF4bHUw@mail.gmail.com>
References: <5380EAF6.1090402@gmail.com>
	<20140529.152809.871745461296745132.davem@davemloft.net>
	<CAHPKR9KmDSgC9EstJLfhqY9SB462OSJhQCEPS7Ka=VvnqbH6iQ@mail.gmail.com>
	<20140530.134245.1805237850303710369.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:58880 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785AbaFCOPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 10:15:41 -0400
Received: by mail-we0-f182.google.com with SMTP id t60so6921423wes.13
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 07:15:40 -0700 (PDT)
In-Reply-To: <20140530.134245.1805237850303710369.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 31, 2014 at 2:12 AM, David Miller <davem@davemloft.net> wrote:
> From: Balakumaran Kannan <kumaran.4353@gmail.com>
> Date: Fri, 30 May 2014 18:35:43 +0530
>
>> All these drivers call netif_carrier_off function after registering
>> the network device using register_netdev.
>
> I can quote more counter-examples than your list, starting with the
> Broadcom tg3 driver.

Thank you David for this information. I'll send updated patch as version-2.

Still I couldn't understand the reason behind this. I should be grateful if you
would explain me little bit.

Regards,
K.Balakumaran
