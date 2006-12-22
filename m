From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] fix cfg80211 WE compat code
Date: Fri, 22 Dec 2006 00:30:46 -0500
Message-ID: <1166765446.8216.3.camel@dv>
References: <1165654123.2816.29.camel@portland.localdomain>
	 <20061209160640.GA3365@tuxdriver.com>
	 <87hcw49rg8.fsf@briny.internal.ondioline.org>
	 <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
	 <1165756653.3131.1.camel@johannes.berg>
	 <20061210110802.kq50mvc4s00s0skw@webmail.spamcop.net>
	 <1165767697.3131.29.camel@johannes.berg>  <1166756032.2262.10.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@briny.ondioline.org>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:49346 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945940AbWLVFay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 00:30:54 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1Gxcza-0007pM-Ru
	for netdev@vger.kernel.org; Fri, 22 Dec 2006 00:30:50 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1166756032.2262.10.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-21 at 21:53 -0500, Pavel Roskin wrote:
> On Sun, 2006-12-10 at 17:21 +0100, Johannes Berg wrote:
> > John, please apply this to wireless-dev if Pavel says it works (I think
> > it should).
> 
> Yes, it's working for me.  Please apply the patch.

Actually, iwpriv without arguments is still hosed.  In this case,
cfg80211_wext_ioctl() returns -EOPNOTSUPP.

I also noticed that cfg80211_wext_ioctl() sometimes returns 0 although
no drivers I'm using are cfg80211 capable.

It looks like we need a better solution.  I'll try to be more responsive
when it comes to testing.

-- 
Regards,
Pavel Roskin


