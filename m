From: Cong Wang <cwang@twopensource.com>
Subject: Re: [fw filter]: Broken! fw mark based tc class selection not working
Date: Fri, 11 Sep 2015 13:32:34 -0700
Message-ID: <CAHA+R7P5jTGBof-oObzJ0SidRr17fKLGjoMkk0-VYzuSLjawZg@mail.gmail.com>
References: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:35449 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbbIKUcf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2015 16:32:35 -0400
Received: by ykdu9 with SMTP id u9so103885829ykd.2
        for <netdev@vger.kernel.org>; Fri, 11 Sep 2015 13:32:34 -0700 (PDT)
In-Reply-To: <CAA5aLPhvkEPpDhaxSNWnGHU2H0WmCaYhbo-fYKP8+Xzka3-q=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2015 at 9:34 AM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
> Recently I came to know that,
> Without any options fw classifier maps fwmark to classid.
>
> tc filter add dev <iface> parent <qhandle> protocol ip prio 1 fw
>
> i.e. if my packet has mark(0x10001) and class id is not set,
> then above tc filter, will set class id = 0x10001 i.e. 1:1
>
> But when I am trying it out, its not working!
> I am having class 1:1 defined but its not at all hit.

Did you specify a right filter handle? What is your setup?
