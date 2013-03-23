From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1]core:Change a wrong explain about dev_get_by_name
Date: Fri, 22 Mar 2013 18:32:04 -0700
Message-ID: <1364002324.4431.84.camel@edumazet-glaptop>
References: <CA+qZnSSMfbeGsThYe-=tK-kZ3h1GEKDGkNom+07-hRSqgLUUWg@mail.gmail.com>
	 <1363793549.3333.12.camel@edumazet-glaptop>
	 <1363799443.2677.2.camel@bwh-desktop.uk.solarflarecom.com>
	 <1363801389.3333.25.camel@edumazet-glaptop>
	 <CA+qZnST22XrkFgsNqE8aAziD++4EZXzBGzM-4GNbbxfi8z+yvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net
To: tingwei liu <tingw.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:47981 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422660Ab3CWBcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 21:32:08 -0400
Received: by mail-da0-f54.google.com with SMTP id p1so2471629dad.27
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 18:32:07 -0700 (PDT)
In-Reply-To: <CA+qZnST22XrkFgsNqE8aAziD++4EZXzBGzM-4GNbbxfi8z+yvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-03-23 at 09:24 +0800, tingwei liu wrote:
> On Thu, Mar 21, 2013 at 1:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Wed, 2013-03-20 at 17:10 +0000, Ben Hutchings wrote:
> >
> >> If they are wrongly documented as 'can be called from any context', yes.
> >
> > Wow, thats really useful.
> >
> > Why is this function not allowed from hard irq context, we have no idea.
> When function "list_netdevice" get write lock "dev_base_lock" only
> disable soft interrupt. So dev_get_by_name get read lock
> "dev_base_lock", can not called on interrupt context.


dev_get_by_name() doesn't read lock dev_base_lock
since commit 72c9528bab94cc052

This was back to linux-2.6.33

Are you sending patches for older kernel versions per chance ?
