From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] softmac: Fix handling of authentication failure
Date: Fri, 02 Jun 2006 11:09:56 +0100
Message-ID: <44800E74.9070605@gentoo.org>
References: <20060601143722.D0B2C89CF47@zog.reactivated.net> <447FA5B5.8020707@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:40120 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751264AbWFBKJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 06:09:49 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <447FA5B5.8020707@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry Finger wrote:
> This statement fails to compile on my system using Linus' tree, because 
> ieee80211softmac_disassoc needs a second argument - the reason. It seems 
> as if WLAN_REASON_PREV_AUTH_NOT_VALID would be appropriate.

Thanks for pointing that out. This patch depends on a patch titled 
"softmac: deauthentication implies deassociation" which is apparently 
not present in Linus' tree.

Daniel
