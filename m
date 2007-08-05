From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [Rt2400-devel] [BUG] rt2x00: inconsistent lock state
Date: Sun, 5 Aug 2007 22:46:43 +0200
Message-ID: <200708052246.43203.IvDoorn@gmail.com>
References: <20070805194554.GA17141@dreamland.darkstar.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:55072 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762716AbXHEUl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2007 16:41:57 -0400
Received: by ug-out-1314.google.com with SMTP id j3so581481ugf
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2007 13:41:56 -0700 (PDT)
In-Reply-To: <20070805194554.GA17141@dreamland.darkstar.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> If I'm reading the state bits and the message correcly dev_base_lock was
> aquired for write with IRQ enabled (via register_netdevice), but lockep also
> saw it aquired for read *in* IRQ (hardirq) context (rt2x00 code path, via
> rt2x00lib_beacondone -> ieee80211_beacon_get); this means that a deadlock can
> occur if we take an interrupt while the lock is already held.
> So either the lock must be IRQ-safe (_irq() / _irq_save()) or rt2x00 must not
> take it in interrupt context.

This has already been fixed in rt2x00.git
I am still working on resolving some other issues,
but the rt2x00 2.0.7 release will contain the fix for this.

Ivo
