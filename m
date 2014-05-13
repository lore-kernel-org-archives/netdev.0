From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bonding directly changes underlying device address
Date: Tue, 13 May 2014 13:55:27 +0200
Message-ID: <20140513115527.GC2910@minipsycho.orion>
References: <5371FCD0.7050502@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	netdev <netdev@vger.kernel.org>,
	Noa Osherovich <noaos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:61993 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbaEMLzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 07:55:31 -0400
Received: by mail-ee0-f54.google.com with SMTP id b57so338841eek.13
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 04:55:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5371FCD0.7050502@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 13, 2014 at 01:06:56PM CEST, ogerlitz@mellanox.com wrote:
>Hi Jay, Veaceslav
>
>I see  now that alb_set_slave_mac_addr directly changes the
>underlying device mac address without calling dev_set_mac_address
>when running in TLB mode. Is that on purpose? if yes, can you explain
>why?

I believe that is a bug. dev_addr change should be always done using
dev_set_mac_address.

>
>I suspect this can lead to funny (or actually sad) bugs in networking
>drivers, can we avoid that?
>
>Or.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
