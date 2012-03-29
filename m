From: Richard Farina <sidhayn@gmail.com>
Subject: Re: compat-wireless releases based on v3.3
Date: Wed, 28 Mar 2012 21:45:04 -0400
Message-ID: <4F73BEA0.1030305@gmail.com>
References: <CAB=NE6WgTMdDtU4_ZgYVr2XzSuiicT5o=q2RvV24jeQj0rZfFw@mail.gmail.com> <4F72BB7F.8080704@gmail.com> <CAB=NE6WFM-BPQ41kPaod-7qkHnT5MXCUc2hdKXDVzrdPq2brjA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org,
	lf_driver_backport@lists.linux-foundation.org
To: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:55835 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756083Ab2C2BoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 21:44:03 -0400
In-Reply-To: <CAB=NE6WFM-BPQ41kPaod-7qkHnT5MXCUc2hdKXDVzrdPq2brjA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/12 03:43, Luis R. Rodriguez wrote:
> On Wed, Mar 28, 2012 at 12:19 AM, Richard Farina <sidhayn@gmail.com> wrote:
>> /var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:
>> In function 'carl9170_tx_ps_drop':
>> /var/tmp/portage/net-wireless/compat-wireless-3.3/work/compat-wireless-3.3-1-n/drivers/net/wireless/ath/carl9170/tx.c:1248:26:
>> error: 'IEEE80211_TX_CTL_POLL_RESPONSE' undeclared (first use in this
>> function)
> linux-next-cherry-picks/0007-mac80211-handle-non-bufferable-MMPDUs-correctly.patch
>
> is to be blamed for. This is fixed, new tarball:
>
> http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-2-n.tar.bz2
> sha1sum: dd18cfabbe705a75440fd7fbe50a09d5fe34bb70
Confirmed, I am able to build 3.3-2-n with no issues.

Thanks!

-Rick
> Thanks for reporting this. Just FYI -- I am working to use ckmake on
> compat-wireless.git to build test against all supported kernels prior
> to release just as I am doing now for compat.git, but the current
> development cycle still a few items which require a bit of work to
> backport to fix compilation against older kernels. That is the goal
> though, so that future releases area always guaranteed to compile
> against all supported stable kernel releases listed on kernel.org.
>
>   Luis
>
