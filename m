From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Thu, 7 Mar 2013 21:41:20 +0100
Message-ID: <20130307204120.GA3808@x61s.8.8.8.8>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:63518 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab3CGUkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:40:08 -0500
Received: by mail-ea0-f169.google.com with SMTP id d13so29750eaa.14
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 12:40:07 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I don't know if this is a right solution for that, because other
functions like addrconf_ifid_infiniband to manipulate eui after memcpy,
too.

But this patch solves my problems with ieee802154 stack.

Any other ideas?

Regards
Alex
