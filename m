From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net] ipv6: restore the behavior of ipv6_sock_ac_drop()
Date: Fri, 5 Sep 2014 15:41:28 -0700
Message-ID: <CAHA+R7N+WGNV5yTQ_hVbn-ez4Ar9395HzOGUU4tG9uLHqFPndA@mail.gmail.com>
References: <1409952780-24471-1-git-send-email-xiyou.wangcong@gmail.com>
	<1409955985.1192797.164218289.4192DDA7@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Sabrina Dubroca <sd@queasysnail.net>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:48935 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbaIEWla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 18:41:30 -0400
Received: by mail-la0-f54.google.com with SMTP id b17so14411739lan.41
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 15:41:28 -0700 (PDT)
In-Reply-To: <1409955985.1192797.164218289.4192DDA7@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 5, 2014 at 3:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Cong,
>
> Just doing normal review, really no bad intentions, just technical
> follow-up. ;)

I believe you are not supposed to do it since definitely you
said you don't want to work with me. You said it, not me,
I respect any of your choice. :)

>
> On Fri, Sep 5, 2014, at 23:33, Cong Wang wrote:
>> It is possible that the interface is already gone after joining
>> the list of anycast on this interface as we don't hold a refcount
>> for the device, in this case we are safe to ignore the error.
>
> anycast code actually inserts routes into the routing table and holds a
> reference on the interface while that route is active.

But route could be deleted.

>
>> What's more important, for API compatibility we should not
>> change this behavior for applications even if it were correct.
>
> IMHO adding new error codes never breaks existing applications because
> there is no way they can explore all possible errno variables. Also we
> already report ENODEV from multicast setsockopts. So I think it would be
> ok to leave it as is, but I have no strong opinion on that and it would
> be ok by me if the patch got accepted (maybe update the changelog).
>

Again, too late to change, the code has been there since the beginning
of git history. You should have a strong argument if you want to change it,
otherwise restore old behavior, that is all. Obviously you don't even mention
this when you accept that patch.
