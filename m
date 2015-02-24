From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 01/29] fib_trie: Convert fib_alias to hlist from
 list
Date: Tue, 24 Feb 2015 17:08:19 -0500 (EST)
Message-ID: <20150224.170819.1223923082073420924.davem@davemloft.net>
References: <20150224202837.26106.87623.stgit@ahduyck-vm-fedora20>
	<20150224204801.26106.10186.stgit@ahduyck-vm-fedora20>
	<CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51516 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbBXWIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:08:25 -0500
In-Reply-To: <CAJ3xEMhn6R9heFGtEB4-uxb2SHc2XWZv2oX_7pYhZVYZo5MeFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Tue, 24 Feb 2015 23:51:40 +0200

> On Tue, Feb 24, 2015 at 10:48 PM, Alexander Duyck
> <alexander.h.duyck@redhat.com> wrote:
>> There isn't any advantage to having it as a list and by making it an hlist
>> we make the fib_alias more compatible with the list_info in terms of the
>> type of list used.
> 
> Hi Alex, twenty nine patches without (unless it's on his way) cover
> letter are really hard to grasp, can you write something general on
> this series, please...

There was a 00/29 posting.
