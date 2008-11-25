From: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Subject: Re: pull request: wireless-2.6 2008-11-25
Date: Tue, 25 Nov 2008 14:52:23 -0800
Message-ID: <20081125225223.GI5950@tesla>
References: <20081125220824.GB25962@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<zenczykowski@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753802AbYKYWwl@vger.kernel.org>
Received: from mail.atheros.com ([10.10.20.108])
	by sidewinder.atheros.com
	for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 14:52:26 -0800
Content-Disposition: inline
In-Reply-To: <20081125220824.GB25962@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 25, 2008 at 02:08:24PM -0800, John W. Linville wrote:
> Dave,
> 
> These fixes are intended for 2.6.28.  Included are a build fix,
> a security issue (debugfs permissions), a fixup to a previous patch
> from Johannes to correct some DMA API usage, a fix to prevent mac80211
> from allowing the use of IBSS mode on channels that don't allow it,
> an ath5k fix to limit wakeups when not associate, and some ath9k DMA
> fixes for a problem that led to disk corruption...

BTW, just for the record, the culprit to disk corruption on ath9k
seems to be a bug in the swiotlb emergency buffer. If bored please
bugzilla 11811 [1] for more information and also a suggested patch
for how to fix this by Maciej, which he should be sending to
linux-kernel soon hopefully.

The swiotlb issue should not affect us anymore though as we now don't starve
the swiotlb of bounce buffers and hence no reason to rely on the buggy
emergency buffer.

[1] http://bugzilla.kernel.org/show_bug.cgi?id=11811

  Luis
