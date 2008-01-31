From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/6][NETNS]: Make bind buckets live in net namespaces.
Date: Thu, 31 Jan 2008 05:06:10 -0800 (PST)
Message-ID: <20080131.050610.256949086.davem@davemloft.net>
References: <47A1C09B.6090202@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764948AbYAaNFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 08:05:49 -0500
In-Reply-To: <47A1C09B.6090202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 31 Jan 2008 15:35:39 +0300

> This tags the inet_bind_bucket struct with net pointer,
> initializes it during creation and makes a filtering
> during lookup.
> 
> A better hashfn, that takes the net into account is to
> be done in the future, but currently all bind buckets
> with similar port will be in one hash chain.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
