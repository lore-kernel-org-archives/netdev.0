From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net_sched: avoid generating same handle for u32 filters
Date: Sat, 19 Jul 2014 15:15:25 -0700
Message-ID: <CAM_iQpU8P=sgbtOfjZ8QD6maoMCfwoiTgEsiEVG7M=j3M3v22g@mail.gmail.com>
References: <1405643693-4880-1-git-send-email-xiyou.wangcong@gmail.com>
	<53CAEC2F.4050808@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:60517 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299AbaGSWPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2014 18:15:25 -0400
Received: by mail-oa0-f48.google.com with SMTP id m1so5448764oag.35
        for <netdev@vger.kernel.org>; Sat, 19 Jul 2014 15:15:25 -0700 (PDT)
In-Reply-To: <53CAEC2F.4050808@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 19, 2014 at 3:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> No fundamental objection - question though: What happens if i was to specify
> the handle when i provision the filter?
> Side note: these handles + other info are used to "route" around
> hash trees for filters.
>

gen_new_kid() is called only when handle is not specified by user.
