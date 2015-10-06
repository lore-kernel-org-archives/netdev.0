From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 11:28:08 -0700
Message-ID: <CALnjE+pvenVjpyKHKjyqj-mWi9tgUtWs2mOUKhX1+O-0XkP3jQ@mail.gmail.com>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
	<20151005204020.56f50496@griffin>
	<CALnjE+rOO2Db-fk9zNgY6Wn1q_57Pr=ABB2vOf_L4zM_7Z8Sfw@mail.gmail.com>
	<20151006175634.200d69a0@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36332 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbbJFS2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:28:09 -0400
Received: by ioii196 with SMTP id i196so231342805ioi.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:28:08 -0700 (PDT)
In-Reply-To: <20151006175634.200d69a0@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 6, 2015 at 8:56 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Mon, 5 Oct 2015 12:37:50 -0700, Pravin Shelar wrote:
>> That would involve lot of refactoring vxlan xmit code. I do not want
>> to make such change in net tree at such late stage.
>
> Fair enough. But then, the minimal fix for net.git would be just
> modifying the current get_egress_tun_info handlers in vport-*.c,
> wouldn't it? I'd say let's go this way and fix this properly for
> net-next. See my other mail for my comments on the patch.
>
What do you have in mind? I do not see way to fix this issue in vport-*.c.
