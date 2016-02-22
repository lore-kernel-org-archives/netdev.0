From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: add network namespace support for tc actions
Date: Mon, 22 Feb 2016 15:51:51 -0800
Message-ID: <CAM_iQpVBBE6aah=5YNuBt0G+5Zb7eB-O97FVaYLWLSOjAMrCMQ@mail.gmail.com>
References: <1455928994-9726-1-git-send-email-xiyou.wangcong@gmail.com>
	<56C8B21E.7070307@iogearbox.net>
	<CAM_iQpWzVoy7eYdf2Yxz2qfoAO5-pDZioACyu7Hws6u7vvP1Yw@mail.gmail.com>
	<56CB1053.8020102@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33285 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432AbcBVXvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 18:51:52 -0500
Received: by mail-yk0-f169.google.com with SMTP id z13so68953631ykd.0
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2016 15:51:51 -0800 (PST)
In-Reply-To: <56CB1053.8020102@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 5:42 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> I did a quick look and i am struggling with it. The patch seems largish
> The issue is that we need to do this per kernel module so the code
> churn maybe unavoidable; hinfo stored in act_ops complicates things.
> Having said that:  All the pernet operations in your
> code seem to be generic, other than to accomodate for module specific
> act_ops. Is it possible to make generic pernet operations? This way
> you could do things at tcf_register_action() for all actions.
> The challenge seems to be in the xxx_net_id which appears(sorry didnt
> look closely at the namespace code) to need to be unique id per module
> and per namespace instance - otherwise i would suggest for xxx_net_id

I got some idea to reduce the duplicated code, not all but most.

> to be part of act_ops. Could we not have an #ifdef in the namespace
> core like the netfilter code does and have one level of indirection
> for everything but the namespace 0?

I believe this should be done in a separated patch if really needed.

Thanks.
