From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Sat, 5 Mar 2016 09:58:54 +0300
Message-ID: <20160305065854.GK4184@uranus.lan>
References: <20160304213920.GJ4184@uranus.lan>
 <20160304.175032.1728003538386465719.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35165 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbcCEG7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2016 01:59:04 -0500
Received: by mail-lb0-f180.google.com with SMTP id bc4so83249739lbc.2
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 22:59:03 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160304.175032.1728003538386465719.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 04, 2016 at 05:50:32PM -0500, David Miller wrote:
> 
> Arbitrary limits are... arbitrary.
> 
> If the freeing loop is the issue, splice the list at teardown and
> process that list asynchronously via a workqueue or similar.

Thanks! I'll try.
