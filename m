From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: core: fix wrong linkage for
 ptype_base and ptype_all symbols
Date: Tue, 06 Aug 2013 14:06:41 -0700
Message-ID: <1375823201.4004.13.camel@edumazet-glaptop>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
	 <1375774371-831-3-git-send-email-sakiwit@gmail.com>
	 <5200B01B.9080705@redhat.com> <20130806204508.GA2274@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: Jean Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:40371 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3HFVGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 17:06:43 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so1254463pab.7
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 14:06:42 -0700 (PDT)
In-Reply-To: <20130806204508.GA2274@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 14:45 -0600, Jean Sacren wrote:

> I'm sorry to tell you but the patch is correct. Both symbols of
> ptype_{base,all} were wrongly declared as extern in net-procfs.c in the
> first place.

You are mistaken.

> > The net-procfs.c usage of ptype_* is there to show current pf_packet users
> > via seq_files in procfs. Your patch will just break this.
> 
> I validated it before I submitted the patch that all the symbols of
> ptype_{base,all} are used exclusively in net/core/net-procfs.c and
> net/core/dev.c but not outside of those two places. Therefore, your
> assumption for breakage is groundless.
> 
> As a kernel networking guru as you are, you shall have the lab and all
> sorts of test cases to validate patches. I'd love to run this type of
> testing by myself, but I don't have such resources. If you could test
> this patch in any of your setup and prove that I'm wrong, I'd extremely
> appreciate it. Thank you in advance.
> 
> I'm looking forward to being taught more.
> 


Well, the patch is wrong, for sure, and you cannot ask us to test your
patches.

Do not send patches that you cannot test yourself, please.

Try this before/after your patch

cat /proc/net/ptype
