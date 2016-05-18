From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net] fou: avoid using sk_user_data before it is initialised
Date: Wed, 18 May 2016 10:16:18 -0700
Message-ID: <CALx6S35_owy-0ani--u5H=jQ1PTAcNprbZWNh+QBmHVgCe98NQ@mail.gmail.com>
References: <1463560216-26616-1-git-send-email-simon.horman@netronome.com>
	<CALx6S35yHpUk2NQe+JAUYcY7mMBLWRuy75egsDCCB3dmhrC1Ng@mail.gmail.com>
	<CAM_iQpWJ1BXk9wSypFSacVbHtF2xUEscYByD=qp56rO_5bXAeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:33778 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932598AbcERRQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:16:20 -0400
Received: by mail-ig0-f194.google.com with SMTP id rc4so5240673igc.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:16:19 -0700 (PDT)
In-Reply-To: <CAM_iQpWJ1BXk9wSypFSacVbHtF2xUEscYByD=qp56rO_5bXAeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 10:07 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Wed, May 18, 2016 at 9:30 AM, Tom Herbert <tom@herbertland.com> wrote:
>> On Wed, May 18, 2016 at 1:30 AM, Simon Horman
>> <simon.horman@netronome.com> wrote:
>>> During initialisation sk->sk_user_data should be initialised before
>>> it is referenced via a call to gue_encap_init().
>>>
>> I think this is should be fixed by proposed patch "fou:
>> Call-setup_udp_tunnel_sock".
>
> That is 6/16, do you have a fix for stable to backport?

Your patch to use fou directly is good.

Tom
