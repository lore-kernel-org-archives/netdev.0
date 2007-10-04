From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] mac80211: Fix TX after monitor interface is converted
	to managed
Date: Thu, 4 Oct 2007 18:13:58 -0400
Message-ID: <20071004221358.GM6037@tuxdriver.com>
References: <20071004113343.552139D502B@zog.reactivated.net> <200710041706.06182.mb@bu3sch.de> <20071004151956.GE6037@tuxdriver.com> <200710041311.37997.flamingice@sourmilk.net> <20071004181516.GH6037@tuxdriver.com> <ada4ph6bm8h.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mb@bu3sch.de>, Daniel Drake <dsd@gentoo.org>,
	johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2704 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758520AbXJDWjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2007 18:39:06 -0400
Content-Disposition: inline
In-Reply-To: <ada4ph6bm8h.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 04, 2007 at 02:31:26PM -0700, Roland Dreier wrote:
>  > Programming with assertions (and BUG_ON is a form of that) is
>  > generally a good practice.  Almost any book or other source on

> The problem with BUG_ON is that it kills the whole system.  So every
> time you add a BUG_ON into code, you have to weigh whether the problem
> you detected is so severe that the right response is to panic.  For
> example, I can see panicking on something fundamental like corrupted
> page tables.  However I would submit that the wireless stack should
> *never* use BUG_ON -- printing a warning and trying to limp on seems
> preferable to me.

OK, I'll buy that as an argument to use WARN_ON instead of BUG_ON.
But it doesn't invalidate the desire to have some sort of assertion.

John
-- 
John W. Linville
linville@tuxdriver.com
