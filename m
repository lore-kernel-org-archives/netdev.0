From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Fri, 9 May 2014 12:22:14 -0700
Message-ID: <CAM_iQpWsbvC8nZd31n+akt2tQfCKvsHW6WAfjFdsgKNc5iiVig@mail.gmail.com>
References: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140509110345.417d2b90@nehalam.linuxnetplumber.net>
	<CAM_iQpUJ7q_RgFzJ7yu5F0aYSSCVAEu64UpwN=md0OyRGHBFAg@mail.gmail.com>
	<20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:36644 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757088AbaEITWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 15:22:15 -0400
Received: by mail-oa0-f49.google.com with SMTP id eb12so5350960oac.8
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 12:22:14 -0700 (PDT)
In-Reply-To: <20140509120241.3b628dc1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 9, 2014 at 12:02 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri, 9 May 2014 11:10:36 -0700
> Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>>
>> This can't be done without a macro (at least for me). Or
>> we have to duplicate the code.
>
> macro method is too ugly, figure out a better way.

That's what I am going to do for -net-next. This patch is for -net,
it's an ugly but minimum change I can find.

Of course, if you insist we should clean up it for -net as well,
I can do that.
