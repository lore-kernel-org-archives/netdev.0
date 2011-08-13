From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Fri, 12 Aug 2011 17:33:24 -0700
Message-ID: <CA+mtBx-nezRVZ7Q3h1uFCycEK6bL+ZsBR8Go69KsMu+g0UYvLw@mail.gmail.com>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110812112025.5788de0b@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:58385 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752371Ab1HMAd2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 20:33:28 -0400
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p7D0XQDG000919
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 17:33:26 -0700
Received: from iyk2 (iyk2.prod.google.com [10.241.51.130])
	by wpaz13.hot.corp.google.com with ESMTP id p7D0X6Uh013480
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 17:33:25 -0700
Received: by iyk2 with SMTP id 2so2084126iyk.18
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 17:33:24 -0700 (PDT)
In-Reply-To: <20110812112025.5788de0b@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 1. Need a way to configure the values. =A0My preference would be new
> =A0 netlink attribute and via 'ip link set' ...
>
As opposed to using sysfs entries?

> 2. Does this need to know the speed of the link (autonegotiation) or

No.

> =A0 is it self clocking?

It is self clocking.  The only time related tunable is hold_time
(which I think can have a reasonable default).

Tom
