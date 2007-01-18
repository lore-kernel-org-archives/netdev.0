From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Thu, 18 Jan 2007 15:16:31 +0200
Message-ID: <20070118131631.GA24622@ee.oulu.fi>
References: <87bqky759v.fsf@ten22.rhodesmill.org> <87mz4h61p0.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:48970 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932422AbXARNmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 08:42:46 -0500
To: Brandon Craig Rhodes <brandon@rhodesmill.org>
Content-Disposition: inline
In-Reply-To: <87mz4h61p0.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 11:46:35AM -0500, Brandon Craig Rhodes wrote:
> Having further reviewed my code, I have changed my mind; the
> ieee80211_crypt_tkip routines are not designed to be responsible for
> creating enough headroom and tailroom.  The "hostap" driver should be
> doing this.  In fact, I now see that the "hostap" driver actually
> attempts to create enough headroom and tailroom, but computes them
> incorrectly.
Even then, if ieee80211_tkip_encrypt() didn't produce debug output for the
not enough space-case, should that be added to catch other
potentially broken drivers?
