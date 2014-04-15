From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 2/3] ipv4,fib: pass LOOPBACK_IFINDEX instead of 0 to flowi4_iif
Date: Tue, 15 Apr 2014 16:25:10 -0700
Message-ID: <CAM_iQpWGivLAXGepMM1nn7mQZDr5=BTP148Avz3kCFxgzrFBnQ@mail.gmail.com>
References: <1397525608-11592-1-git-send-email-xiyou.wangcong@gmail.com>
	<1397525608-11592-2-git-send-email-xiyou.wangcong@gmail.com>
	<alpine.LFD.2.11.1404152315130.1549@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Biederman <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:41083 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbaDOXZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 19:25:11 -0400
Received: by mail-oa0-f41.google.com with SMTP id j17so11772494oag.0
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 16:25:10 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1404152315130.1549@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 15, 2014 at 1:26 PM, Julian Anastasov <ja@ssi.bg> wrote:
>
>         Hello,
>
> On Mon, 14 Apr 2014, Cong Wang wrote:
>
>> From: Cong Wang <cwang@twopensource.com>
>>
>> flowi4_iif should be LOOPBACK_IFINDEX by default.
>
>         Looks good to me, you included all needed changes
> into the 3 patches. After checking all fib_lookup() callers
> I see one remaining place to be fixed, if we want to be
> pedantic: fib_check_nh() needs a LOOPBACK_IFINDEX for fl4.
>

I will add it too. Thanks a lot!
