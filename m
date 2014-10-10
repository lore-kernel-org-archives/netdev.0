From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 0/5] net: fix races accessing page->_count
Date: Thu, 09 Oct 2014 22:42:44 -0700
Message-ID: <1412919764.9362.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
	 <CAL3LdT4B3eN55ALtJFxC0ZxgkopOg+5B5JbpDajXJ=0-QOVfuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:52688 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982AbaJJFmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:42:46 -0400
Received: by mail-pa0-f41.google.com with SMTP id eu11so1085817pac.0
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 22:42:46 -0700 (PDT)
In-Reply-To: <CAL3LdT4B3eN55ALtJFxC0ZxgkopOg+5B5JbpDajXJ=0-QOVfuA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-09 at 22:37 -0700, Jeff Kirsher wrote:

> Looks like the ixgbe patch has the incorrect title, or you patch igb twice. :-)

Yes, typo in the title, but content is OK, sorry.
