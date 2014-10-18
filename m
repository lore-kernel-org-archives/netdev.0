From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] vxlan: remove the dead codes
Date: Sat, 18 Oct 2014 11:20:44 +0200
Message-ID: <20141018112044.77939a2e@uryu.home.lan>
References: <1413525844-2406-1-git-send-email-roy.qing.li@gmail.com>
	<CAHA+R7O7Yyd2XMkMnv5b_TLFekPCRRtOGG7bHgHs2Qd+YRu3Hg@mail.gmail.com>
	<20141017.162449.747433271390481594.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, roy.qing.li@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:64474 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaJRJVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 05:21:11 -0400
Received: by mail-la0-f46.google.com with SMTP id gi9so1832741lab.33
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 02:21:09 -0700 (PDT)
In-Reply-To: <20141017.162449.747433271390481594.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Oct 2014 16:24:49 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Cong Wang <cwang@twopensource.com>
> Date: Fri, 17 Oct 2014 10:33:08 -0700
> 
> > On Thu, Oct 16, 2014 at 11:04 PM,  <roy.qing.li@gmail.com> wrote:
> >> From: Li RongQing <roy.qing.li@gmail.com>
> >>
> >> remove the dead codes, no user uses vxlan_salt
> >>
> >> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> >> ---
> >>  drivers/net/vxlan.c |    4 ----
> >>  1 file changed, 4 deletions(-)
> >>
> >> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> >> index 77ab844..855a81d 100644
> >> --- a/drivers/net/vxlan.c
> >> +++ b/drivers/net/vxlan.c
> >> @@ -152,8 +152,6 @@ struct vxlan_dev {
> >>         struct hlist_head fdb_head[FDB_HASH_SIZE];
> >>  };
> >>
> >> -/* salt for hash table */
> >> -static u32 vxlan_salt __read_mostly;
> > 
> > Hmm, it has never been used since it was born. Maybe we should
> > really use for vxlan hash table?
> 
> Yes, agreed, and I am very sure that this was Stephen Hemminger's
> original intention.

yes. never did rekeying, and it would have been hard.
