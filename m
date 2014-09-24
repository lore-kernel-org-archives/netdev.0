From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 03/24] net: rbridge: Add RBridge structure
Date: Wed, 24 Sep 2014 09:40:48 -0700
Message-ID: <20140924094048.05fbd3ea@urahara>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
	<1411573940-14079-4-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, william@gandi.net,
	f.cachereul@alphalink.fr, Kamel Haddadou <kamel@gandi.net>
To: Ahmed Amamou <ahmed@gandi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57163 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484AbaIXQlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 12:41:00 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so4771307pdb.0
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 09:41:00 -0700 (PDT)
In-Reply-To: <1411573940-14079-4-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2014 17:51:59 +0200
Ahmed Amamou <ahmed@gandi.net> wrote:

> +struct rbr_nickinfo {
> +	/* Nickname of the RBridge */
> +	uint16_t nick;
> +	/* Next-hop SNPA address to reach this RBridge */
> +	u8 adjsnpa[ETH_ALEN];

Be consistent, always use kernel types (u16) not stdint types (uint16_t)
