From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: use list_move instead of list_del/list_add
Date: Thu, 06 Sep 2012 11:56:22 +0200
Message-ID: <1346925382.5469.5.camel@jlt4.sipsolutions.net>
References: <CAPgLHd_VrjzzfPDsd3KKzgX2bKJ47zUCJmsQO+Q49ajNVLnTVg@mail.gmail.com>
	 (sfid-20120906_072055_477672_C2859B1B)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, yongjun_wei@trendmicro.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48300 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653Ab2IFJzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 05:55:51 -0400
In-Reply-To: <CAPgLHd_VrjzzfPDsd3KKzgX2bKJ47zUCJmsQO+Q49ajNVLnTVg@mail.gmail.com> (sfid-20120906_072055_477672_C2859B1B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 13:20 +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move() instead of list_del() + list_add().
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied. FWIW, I don't think it's really a "problem" rather than a
simplification or something like that, but anyway.

johannes
