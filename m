From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] vxlan: cleanup headers and tx path
Date: Sun, 07 Feb 2016 13:51:26 -0500 (EST)
Message-ID: <20160207.135126.920072469225084082.davem@davemloft.net>
References: <cover.1454432731.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901AbcBGSv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 13:51:29 -0500
In-Reply-To: <cover.1454432731.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Tue,  2 Feb 2016 18:09:10 +0100

> This is first part of vxlan cleanup. It makes vxlan.h better organized and
> removes code duplication in the tx path. There's no change in functionality.
> 
> This is in preparation for VXLAN-GPE support. Other sets will follow with
> cleanup of rx path, modifications of vxlan interface setup and
> cleanup/modification of fdb handling. The goal of these patchsets is to
> consolidate VXLAN extension handling (right now it's scattered all around
> the code) and allow vxlan to operate in L3 mode (i.e. without inner Ethernet
> headers).
> 
> The full picture (all 30 patches) can be seen at:
> https://github.com/jbenc/linux-vxlan/commits/master
> 
> Changelog:
> v2: added patch 5/6, fixing the udp sum problem spotted by Paolo Abeni

Applied, thanks.
