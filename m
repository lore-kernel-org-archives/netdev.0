From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: socket: move ktime2ts to ktime
 header api
Date: Fri, 19 Apr 2013 16:50:39 -0400 (EDT)
Message-ID: <20130419.165039.358502902228449717.davem@davemloft.net>
References: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, hawk@diku.dk
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333Ab3DSUun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 16:50:43 -0400
In-Reply-To: <1366111751-14886-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 16 Apr 2013 13:29:10 +0200

> Currently, ktime2ts is a small helper function that is only used in
> net/socket.c. Move this helper into the ktime API as a small inline
> function, so that i) it's maintained together with ktime routines,
> and ii) also other files can make use of it. The function is named
> ktime_to_timespec_cond() and placed into the generic part of ktime,
> since we internally make use of ktime_to_timespec(). ktime_to_timespec()
> itself does not check the ktime variable for zero, hence, we name
> this function ktime_to_timespec_cond() for only a conditional
> conversion, and adapt its users to it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
