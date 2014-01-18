From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Fri, 17 Jan 2014 19:50:49 -0800
Message-ID: <CAM_iQpUoQcHpQJn-nYp9mO+XXMmXSjFxy3ASwchAH-qECoz9OA@mail.gmail.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com>
	<CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
	<52D97746.1040408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:59131 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbaARDut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 22:50:49 -0500
Received: by mail-oa0-f54.google.com with SMTP id o6so5503783oag.41
        for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 19:50:49 -0800 (PST)
In-Reply-To: <52D97746.1040408@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 17, 2014 at 10:32 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
>
> If you want to do cleanups, whatever, I really don't care.
> You had your chance to complain about that when you reviewed
> the initial version ... it has nothing to do with the fix.

This is not for stable, as long as it doesn't harm the readability
we are free to do any cleanup's.

If unsure, check Eric's patch for tunnel dst cache.

BTW, I am the original author of the patch, you just updated
it *trivially* and set yourself as the author. :) I don't mind, but
remember that this may be not appropriate for others. At
very least I didn't and don't do this myself.
