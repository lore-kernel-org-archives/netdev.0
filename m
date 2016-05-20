From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] fou: avoid using sk_user_data before it is initialised
Date: Thu, 19 May 2016 22:17:40 -0700
Message-ID: <CAM_iQpW2TMHjch6F959LZ171HgeV5Bz-b2sCwtGde1Haw6PyPA@mail.gmail.com>
References: <1463560216-26616-1-git-send-email-simon.horman@netronome.com>
 <CALx6S35yHpUk2NQe+JAUYcY7mMBLWRuy75egsDCCB3dmhrC1Ng@mail.gmail.com>
 <CAM_iQpWJ1BXk9wSypFSacVbHtF2xUEscYByD=qp56rO_5bXAeA@mail.gmail.com> <CALx6S35_owy-0ani--u5H=jQ1PTAcNprbZWNh+QBmHVgCe98NQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f173.google.com ([209.85.161.173]:34532 "EHLO
	mail-yw0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbcETFSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 01:18:00 -0400
Received: by mail-yw0-f173.google.com with SMTP id j74so99575789ywg.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 22:18:00 -0700 (PDT)
In-Reply-To: <CALx6S35_owy-0ani--u5H=jQ1PTAcNprbZWNh+QBmHVgCe98NQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 10:16 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Wed, May 18, 2016 at 10:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Wed, May 18, 2016 at 9:30 AM, Tom Herbert <tom@herbertland.com> wrote:
>>> On Wed, May 18, 2016 at 1:30 AM, Simon Horman
>>> <simon.horman@netronome.com> wrote:
>>>> During initialisation sk->sk_user_data should be initialised before
>>>> it is referenced via a call to gue_encap_init().
>>>>
>>> I think this is should be fixed by proposed patch "fou:
>>> Call-setup_udp_tunnel_sock".
>>
>> That is 6/16, do you have a fix for stable to backport?
>
> Your patch to use fou directly is good.

Note, I am waiting for Simon to update his patch if he agrees.
