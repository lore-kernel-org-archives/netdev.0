From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCH] net: wireless: move regulatory timeout work to
 power efficient workqueue
Date: Fri, 31 Jan 2014 10:42:23 +0100
Message-ID: <1391161343.4141.3.camel@jlt4.sipsolutions.net>
References: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
	 <1391160084.4141.1.camel@jlt4.sipsolutions.net>
	 <20140131093531.GA25559@mtj.dyndns.org>
	 (sfid-20140131_103536_949453_61FB57CB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoran Markovic <zoran.markovic@linaro.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Shaibal Dutta <shaibal.dutta@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:51395 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbaAaJmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 04:42:33 -0500
In-Reply-To: <20140131093531.GA25559@mtj.dyndns.org> (sfid-20140131_103536_949453_61FB57CB)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-31 at 04:35 -0500, Tejun Heo wrote:
> Hello,
> 
> On Fri, Jan 31, 2014 at 10:21:24AM +0100, Johannes Berg wrote:
> > I'm not sure if this is part of a larger patchset actually adding that
> > "system_power_efficient_wq", but maybe it'd be better to expose a
> > function as an API rather than the wq struct?
> > 
> > Something like
> > 
> > scheduled_delayed_work_pwr_efficient(...)?
> 
> While there are some benefits to using dedicated functions for
> specific workqueues, I don't think it brings enough benefits to
> justify adding dedicated API and am unlikely to add new ones.

Fair enough, I guess I'll take those patches in.

johannes
