From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: Bluetooth 6LoWPAN and routing
Date: Thu, 24 Oct 2013 14:25:14 +0200
Message-ID: <20131024122452.GA5491@omega>
References: <5268C214.2040307@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:57043 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab3JXMZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 08:25:21 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so865286eei.13
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 05:25:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5268C214.2040307@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jukka,

On Thu, Oct 24, 2013 at 09:45:40AM +0300, Jukka Rissanen wrote:
> Hi,
> 
> I have been prototyping with BT 6LoWPAN support (using this draft
> http://tools.ietf.org/html/draft-ietf-6lowpan-btle-12 as a
> reference). I sent first version yesterday to linux-bluetooth ml
> http://thread.gmane.org/gmane.linux.bluez.kernel/39394
> 
I see you take many code from the 6lowpan ieee802154 implementation.
(Just notice you drop the original authors from there)

I have a couple of patches to fix a lot of bugs in the current 6LoWPAN
ieee802154 implementation.

Some bugs which I found:

  - Fix race conditions in fragmentation handling
  - Fix UDP compression/uncompressionm, which is completly broken
  - Fragmentation handling isn't rfc4944 compatible

And some other improvements. I see your rfc has the same issues (e.g.
fragmentation race conditions).

Currently I preparing these patches for mainlining.

But my question is:

What we do now, make a generic 6LoWPAN implementation. Or bluetooth,
ieee802154 makes his own implementation?

- Alex
