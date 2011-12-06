From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/13 net-3.1-stable] Stable queue for 3.1.5
Date: Tue, 06 Dec 2011 16:32:50 -0500 (EST)
Message-ID: <20111206.163250.709413251193958704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, eric.dumazet@gmail.com, roland@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556Ab1LFVc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:32:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Greg, I'm only CC:'ing you on this posting just as a FYI that
  "networking stuff is coming" and nothing more, please hit delete
  now, kthx, bye :-) ]

Hey guys, we have an interesting arrangement of interdependent patches
that need to go into -stable for 3.1.x so I decided to post what I have
queued up to solicit feedback.

The primary purpose of this series posting is to get reviewers to find
integration and merge errors I've made.

Eric, I incorporated Flavio's redirect fix even though it gets redone
by your version in a subsequent patch.  This was intentional so that
the backports are easier to validate.

Roland, I'm incorporating the dst_get_neighbour() lockdep splt fix from
Eric to the IB layer so that we can kill all of that fallout in this
series.  I hope you don't mind.

Thanks.
