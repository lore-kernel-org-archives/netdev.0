From: Cong Wang <cwang@twopensource.com>
Subject: Re: Bug 75571
Date: Mon, 2 Jun 2014 10:38:33 -0700
Message-ID: <CAHA+R7P0Xh88FNL_SG9AX3dWFzKJCa_Axe4dKEDCWhaLh9m+FQ@mail.gmail.com>
References: <1401085231.1775.9.camel@anpws>
	<20140601144341.GA4382@lianli>
	<1401705148.1775.29.camel@anpws>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Alex <d77190@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:60122 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751229AbaFBRie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:38:34 -0400
Received: by mail-qa0-f46.google.com with SMTP id w8so3151706qac.33
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 10:38:33 -0700 (PDT)
In-Reply-To: <1401705148.1775.29.camel@anpws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 2, 2014 at 3:32 AM, Alex <d77190@mail.ru> wrote:
>> Perhaps you would like to try version 3.15-rc7 of the kernel and
>> see if you can reproduce the bug?
> I cannot reproduce bug on 3.15-rc7.
>
> In changelog of 3.15-rc7 I see: "net_sched: fix an oops in tcindex
> filter."
> Is there any backport of this patch to 3.2 to check if it fixes problem?
>

It fixes a regression introduced in 3.14. It makes no sense to backport
it to 3.2, nor it is relevant with the bug you reported.

You should try a recent (stable) kernel to help us to debug the problem.
