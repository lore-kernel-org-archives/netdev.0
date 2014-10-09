From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: Linker error in function sys_bpf: undefined reference to `anon_inode_getfd'
Date: Thu, 9 Oct 2014 08:26:18 -0700
Message-ID: <CAMEtUuzD00VW9KPh8XWu94QVRaG62M6D-w+c=CnzOcUu6+h35Q@mail.gmail.com>
References: <87vbnt1js4.fsf@steelpick.2x.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Michal Sojka <sojkam1@fel.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:61155 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755836AbaJIP0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 11:26:19 -0400
Received: by mail-wi0-f169.google.com with SMTP id cc10so1778778wib.0
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 08:26:18 -0700 (PDT)
In-Reply-To: <87vbnt1js4.fsf@steelpick.2x.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 5:59 AM, Michal Sojka <sojkam1@fel.cvut.cz> wrote:
> The error is:
>
>     kernel/built-in.o: In function `sys_bpf':
>     (.text+0x3b4fc): undefined reference to `anon_inode_getfd'

Thanks for the report. Working on a fix.
