From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next v4 1/2] tc: add BPF based action
Date: Wed, 14 Jan 2015 11:27:23 -0800
Message-ID: <CAHA+R7NWShJo_0apkOa5pudpE69EdWkzAQpW00zfO7ePhxt2XA@mail.gmail.com>
References: <1421257404-25452-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:45742 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbbANT1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 14:27:24 -0500
Received: by mail-qa0-f42.google.com with SMTP id dc16so8064429qab.1
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 11:27:23 -0800 (PST)
In-Reply-To: <1421257404-25452-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 9:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> This action provides a possibility to exec custom BPF code.
>

I still don't like it, sorry, not just for your patch, I never like
cls_bpf either, in terms of the user interface and the duplicated
functionalities: cls_bpf vs u32, act_bpf vs gact.

Ideally we should be able to implement them with the same
interface, transparent to users, I think probably because
the nature of bpf implementation somewhat enforces such
interface everywhere, it is clearly overrated.

(I have no idea about eBPF though.)
