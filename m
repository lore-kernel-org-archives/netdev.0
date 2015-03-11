From: Cong Wang <cwang@twopensource.com>
Subject: Re: iproute2: ip netns: Do not delete netns if there any process use it
Date: Wed, 11 Mar 2015 10:07:50 -0700
Message-ID: <CAHA+R7PsYQLVXse5Yjk6K9V==Yw2WUM=rYGi1KPRf+bwZAwDxQ@mail.gmail.com>
References: <20150311074020.GA26477@angus-think.wlc.globallogic.com>
	<CAHA+R7Pwfjg4642i1FMG1mKJN58K+nYhqvN_NnrbQ+uiPXibGQ@mail.gmail.com>
	<20150311165011.GA917@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:40473 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637AbbCKRHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:07:51 -0400
Received: by igal13 with SMTP id l13so41839186iga.5
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:07:50 -0700 (PDT)
In-Reply-To: <20150311165011.GA917@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 11, 2015 at 9:50 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
>
> Sure kernel does and after net0 file was deleted the devices will be
> still alive within net0 till all processes within net0 will exit or will

This is exactly how reference counting works.

> be killed. And there might be case that after deleting net0 it might be
> hard to find these processes and kill them to bring back devices from
> net0 to the initial netns.

It is your responsibility to track the processes you put into the netns.
