From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 10:08:43 +0200
Message-ID: <b2cc26e40910130108l20a27465ld8e84832c461c4fe@mail.gmail.com>
References: <20091013050705.GA2194@1wt.eu> <4AD42B0F.8010809@gmail.com>
	 <20091013073410.GA3792@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:45712 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbZJMIJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 04:09:20 -0400
Received: by gxk4 with SMTP id 4so10695901gxk.8
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2009 01:08:43 -0700 (PDT)
In-Reply-To: <20091013073410.GA3792@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2009 at 9:34 AM, Willy Tarreau <w@1wt.eu> wrote:
>> We receive a pure ACK (wihout DATA).
>> We should receive exactly one such ACK.
>
> No, we will receive other ones because the socket remains in SYN_RECV
> and since the local system ignores this ACK, it will send a SYN-ACK
> again, triggering a new ACK from the client.

Why does it ignore the ACK? Just because that's the simplest
implementation of defer_accept?
