From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] IPv6 MLD updates
Date: Wed, 04 Sep 2013 14:54:01 -0400 (EDT)
Message-ID: <20130904.145401.941734125666252031.davem@davemloft.net>
References: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44822 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756238Ab3IDSyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 14:54:03 -0400
In-Reply-To: <1378246784-21067-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  4 Sep 2013 00:19:36 +0200

> This set contains the non-RFC version of the previous submission entitled
> "[RFC PATCH net-next 0/7] IPv6 MLD updates". Most importantly it contains
> a fix for MLDv1/v2 switchback timeout where hosts currently are switching
> back from v1 compat mode to normal v2 too early (i.e. switchback time was
> <= 30secs instead of >= 260secs on default), and the set also contains a
> patch that allows for v2-only mode as per RFC recommendation. The rest is
> related to cleanups that make the code more readable resp. maintainable.

Series applied, thanks in particular for the 'net' merge conflict resolution
as that helps me a lot.
