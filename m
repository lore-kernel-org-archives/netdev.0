From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 12:19:39 -0500
Message-ID: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1451490447.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	mleitner@redhat.com, vyasevic@redhat.com, daniel@iogearbox.net,
	davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34903 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752046AbbL3RTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:19:41 -0500
In-Reply-To: <cover.1451490447.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-30 at 23:50 +0800, Xin Long wrote:

> besides, this patchset will use transport hashtable to replace
> association hashtable to lookup with rhashtable api. get transport
> first then get association by t->asoc. and also it will make tcp
> style work better.

SCTP already has a hash table, why not simply changing the way items are
hashed into it ?

Sure, storing thousands of sockets in a single hash bucket is not wise.

Switching SCTP to rhashtable at this moment is premature, it is still
moving fast.
