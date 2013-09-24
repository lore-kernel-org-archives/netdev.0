From: David Miller <davem@redhat.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 11:39:53 -0400 (EDT)
Message-ID: <20130924.113953.1275344954032811572.davem@redhat.com>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7355@saturn3.aculab.com>
	<CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@aculab.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab3IXPj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:39:59 -0400
In-Reply-To: <CA+mtBx_y0hK69jcdY5e0MUzAa8hEPwExBDuK9Dn4Ceo5Hkn_iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Sep 2013 08:22:55 -0700

> We use this value for steering, and could use it for other uses like
> connection lookup.

For security reasons we absolutely cannot use it for that purpose,
please stop claiming this.

Any hash function which an attacker can reproduce is attackable.
