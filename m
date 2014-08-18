From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mac80211: fix channel switch for chanctx-based drivers
Date: Mon, 18 Aug 2014 08:53:11 -0500
Message-ID: <CA+55aFy4X9+o3u=gPcsVfO8VHLcdzifefdjMDoH+uB0xKzym9Q@mail.gmail.com>
References: <1408351816.29649.8.camel@dubbel>
	<1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Luca Coelho <luca@coelho.fi>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:47145 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaHRNxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 09:53:12 -0400
In-Reply-To: <1408360749-10233-1-git-send-email-michal.kazior@tieto.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 18, 2014 at 6:19 AM, Michal Kazior <michal.kazior@tieto.com> wrote:
>
> I've verified this fix with iwlmvm & 7260.

So I'm running a kernel with this manually applied, and so far so
good. But I don't know what actually triggered the problem, and it
definitely didn't happen all the time, so my testing of this is
dubious. But the patch certainly seems to match the symptoms. Thanks,

          Linus
