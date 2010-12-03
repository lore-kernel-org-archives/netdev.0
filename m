From: Junchang Wang <junchangwang@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Fri, 3 Dec 2010 17:40:06 +0800
Message-ID: <AANLkTikzqKHcJFq6V_X=wkwyxBtq1fnNVcYC0Kb_QXqD@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	<1291109699.2904.11.camel@edumazet-laptop>
	<AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	<1291127670.2904.96.camel@edumazet-laptop>
	<AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
	<1291176215.2856.383.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rui <wirelesser@gmail.com>, netdev@vger.kernel.org,
	Fenghua Yu <fyu2000@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53837 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932280Ab0LCJkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 04:40:07 -0500
Received: by bwz15 with SMTP id 15so8134775bwz.19
        for <netdev@vger.kernel.org>; Fri, 03 Dec 2010 01:40:06 -0800 (PST)
In-Reply-To: <1291176215.2856.383.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 1, 2010 at 12:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> But its rather important for performance that each cpu store packets
> into its own packet socket or ring buffer, to avoid false sharing
> slowdowns.

Hi Eric,
But the current situation is that a single socket (AF_PACKET for example)
can only create a ring buffer, meaning that multiple cores will compete
for passing data to user-space programs. Right?

>
> With such a setup (split packets to four cpus, then make sure one cpu
> deliver packets to one particular PACKET socket/ring buffer), it should
> really be fast enough.
>

Is there any patch or configuration? I'm preparing such a patch. I wonder
whether there's conflict.


Thanks.

--Junchang
