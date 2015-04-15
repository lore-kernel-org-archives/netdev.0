From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3/4] mac80211-hwsim: Pass rate-ctrl flags and tx-power
 to user-space
Date: Wed, 15 Apr 2015 09:23:58 -0700
Message-ID: <552E909E.6010405@candelatech.com>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>  <1428095523-374-3-git-send-email-greearb@candelatech.com> <1428999345.3019.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:50346 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753AbbDOQYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 12:24:00 -0400
In-Reply-To: <1428999345.3019.9.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2015 01:15 AM, Johannes Berg wrote:
> On Fri, 2015-04-03 at 14:12 -0700, greearb@candelatech.com wrote:
> 
>> +/* Auxilary info to allow user-space to better understand the rate */
>> +struct hwsim_tx_rate2 {
>> +	u16 rc_flags; /* rate-ctrl flags (see mac80211_rate_control_flags) */
> 
> I really don't like this - it ties internal API to userspace API. You
> may argue that this is userspace that is for debug purposes only, but
> I'm sure you'll also scratch your head very confused when I change the
> rate control flags for any reason and your code breaks :)

Is this a documentation only issue (at this point, while code matches)?

Then later, we can add translation to keep user-space API the same
as needed?

And in that case, maybe I'll make it u32 to give room down the road?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
