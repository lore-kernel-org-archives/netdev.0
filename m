From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net] net: try harder to not reuse ifindex when moving
 interfaces
Date: Mon, 19 Oct 2015 08:36:10 -0700
Message-ID: <20151019153609.GA19724@Alexeis-MBP.westell.com>
References: <294c7a9df554506e684adbeb9bbed070e6fed260.1444993627.git.jbenc@redhat.com>
 <20151018151157.GA19163@Alexeis-MBP.westell.com>
 <20151019110649.726f1fe0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Haller <thaller@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34385 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754486AbbJSPgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 11:36:11 -0400
Received: by padhk11 with SMTP id hk11so33085044pad.1
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 08:36:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20151019110649.726f1fe0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 11:06:49AM +0200, Jiri Benc wrote:
> On Sun, 18 Oct 2015 08:11:58 -0700, Alexei Starovoitov wrote:
> > it looks dangerous.
> > Does it mean that 'for (4B) { create new dev; free old dev; }
> > will keep incrementing that max index and dos it eventually?
> 
> This is not changed by this patch in any way. As for the current
> behavior (with or without my patch), by creating and deleting an
> interface, the max index indeed keeps incrementing. There's no DoS,
> however, as the index simply wraps to 1 when reaching maxint. See
> dev_new_index(). This is something I count on in this patch.

makes sense. thanks for explaining.
