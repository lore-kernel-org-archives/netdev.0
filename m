From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: netvsc NAPI
Date: Thu, 23 Feb 2017 15:33:11 -0800
Message-ID: <20170223153311.7c0d99cb@xeon-e3>
References: <20170222093316.303203c3@xeon-e3>
        <20170223.182406.911130671484909443.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35159 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdBWXn2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 18:43:28 -0500
Received: by mail-pf0-f182.google.com with SMTP id 68so469118pfx.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 15:42:34 -0800 (PST)
In-Reply-To: <20170223.182406.911130671484909443.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Feb 2017 18:24:06 -0500 (EST)
David Miller <davem@redhat.com> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Wed, 22 Feb 2017 09:33:16 -0800
> 
> > NAPI for netvsc is ready but the merge coordination is a nuisance.
> > 
> > Since netvsc NAPI support requires other changes that are proceeding through
> > GregKH's char-misc tree. I would like to send the two patches after current net-next
> > and char-misc-next are merged into Linus's tree.
> > 
> > Need these (at a minimum) these changes
> > 
> >  6e47dd3e2938 ("vmbus: expose hv_begin/end_read")
> >  5529eaf6e79a ("vmbus: remove conditional locking of vmbus_write")
> >  b71e328297a3 ("vmbus: add direct isr callback mode")
> >  631e63a9f346 ("vmbus: change to per channel tasklet")
> >  37cdd991fac8 ("vmbus: put related per-cpu variable together")
> > 
> > Please let me know when linux-net is up to date with these.  
> 
> The 'net' tree is now current with Linus's current tree, and all of
> those above commits seem to be there.

Great thanks. I will merge the NAPI and retest.
