From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 net-2.6.26] ip_options_compile cleanup
Date: Sat, 22 Mar 2008 16:36:47 -0700 (PDT)
Message-ID: <20080322.163647.44112344.davem@davemloft.net>
References: <1205930508.24116.14.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754681AbYCVXgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 19:36:36 -0400
In-Reply-To: <1205930508.24116.14.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 19 Mar 2008 15:41:48 +0300

> This set of patches has been originally sent to to netdev@ two weeks
> ago.
> 
> The idea is the following: ip_options->is_data field is checked only
> inside ip_options_compile when opt != NULL. This is possible only on the
> following codepath:
>     ip_options_get_finish
>         opt->is_data = 1;
>         ip_options_compile(opt, NULL)
> 
> ip_options->is_data is not a part of user<->kernel interface and can be
> removed.

All applied and pushed to net-2.6.26, thanks.
