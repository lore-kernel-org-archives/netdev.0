From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: assert_cfg80211_lock warning with Linux v3.5-8833-g2d53492
Date: Wed, 1 Aug 2012 17:51:08 +0200
Message-ID: <5019506C.6020707@broadcom.com>
References: <20120801131232.GA1785@zod.bos.redhat.com>
 <20120801141810.GB27433@tuxdriver.com> <50194D7A.6060400@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Josh Boyer" <jwboyer@redhat.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	"Seth Forshee" <seth.forshee@canonical.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2032 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755610Ab2HAPvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2012 11:51:20 -0400
In-Reply-To: <50194D7A.6060400@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2012 05:38 PM, Arend van Spriel wrote:
>> brcmsmac needs to hold cfg80211_mutex before calling freq_reg_info...
>> > 
>> > It looks like those calls were added in mid-June.
>> > 
> I think mid-june sounds about right. We never observed the warning when
> changes to use regulatory infrastructure were tested/reviewed. Should
> this precondition be mentioned in cfg80211.h?
> 
> Gr. AvS

Diving in further it seems brcmsmac can not grab the cfg80211_mutex. So
another solution is needed.

Gr. AvS
