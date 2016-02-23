From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Tue, 23 Feb 2016 13:24:58 -0500 (EST)
Message-ID: <20160223.132458.488971277682238141.davem@davemloft.net>
References: <56CC7848.2000704@solarflare.com>
	<CALx6S34Pt++Kg=cp+v+gGFQGEDy=eNHtFvtBwd1z-1d2ixOn7Q@mail.gmail.com>
	<CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, ecree@solarflare.com, aduyck@mirantis.com,
	netdev@vger.kernel.org, alexander.duyck@gmail.com
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940AbcBWSZA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 13:25:00 -0500
In-Reply-To: <CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Tue, 23 Feb 2016 09:31:09 -0800

> Most OSs (including Linux with connected TCP sockets) use non-zero IP
> IDs so requiring this would effectively disable GRO.

+1

Any OS that wants to work with SLHC, as I mentioned, has to emit
monotonically increasing IP ID values in all packets, even those with
DF set.
