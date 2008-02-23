From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:19:19 +0100
Message-ID: <200802232119.19717.IvDoorn@gmail.com>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <20080223200637.GA7135@Chamillionaire.breakpoint.cc> <20080223200910.GB7135@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:26187 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbYBWUTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:19:43 -0500
Received: by nf-out-0910.google.com with SMTP id g13so460016nfb.21
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 12:19:40 -0800 (PST)
In-Reply-To: <20080223200910.GB7135@Chamillionaire.breakpoint.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 February 2008, Sebastian Siewior wrote:
> * Sebastian Siewior | 2008-02-23 21:06:37 [+0100]:
> 
> >I add this to the patch desctiption and post a depends on patach
> ARGH, this was CONFIG_WIRELESS_EXT and not MAC80211. You would like to
> see a select or depend statement on that one?

Other drivers do a select on WIRELESS_EXT, so selecting it would be fine.

Ivo


