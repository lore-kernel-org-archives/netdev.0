From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Wed, 17 Jan 2007 11:23:24 -0600
Message-ID: <45AE5B8C.2070407@lwfinger.net>
References: <87bqky759v.fsf@ten22.rhodesmill.org> <87mz4h61p0.fsf@ten22.rhodesmill.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:36892 "EHLO
	mtiwmhc13.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932584AbXAQRZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 12:25:11 -0500
To: Brandon Craig Rhodes <brandon@rhodesmill.org>
In-Reply-To: <87mz4h61p0.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Craig Rhodes wrote:
> 
> Having further reviewed my code, I have changed my mind; the
> ieee80211_crypt_tkip routines are not designed to be responsible for
> creating enough headroom and tailroom.  The "hostap" driver should be
> doing this.  In fact, I now see that the "hostap" driver actually
> attempts to create enough headroom and tailroom, but computes them
> incorrectly.
> 
> I will, per the MAINTAINERS file, head back to the hostap mailing list
> with a patch for hostap_80211_tx.c - this time, CC'ing the official
> maintainer, as I ought; thank you, Michael Wu, for making me aware of
> that bit of courtesy.

This makes sense. I have used the bcm43xx driver with WPA-PSK TKIP encryption for at least a year,
and I have never seen this error.

Larry


