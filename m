From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] mkiss: fix scribble on freed memory
Date: Wed, 6 Jan 2016 23:29:27 +0300
Message-ID: <568D7927.3090607@cogentembedded.com>
References: <20160106145449.28695.13562.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Alan <gnomes@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org,
	davem@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:34538 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438AbcAFU32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:29:28 -0500
Received: by mail-lb0-f169.google.com with SMTP id pv2so212645801lbb.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 12:29:27 -0800 (PST)
In-Reply-To: <20160106145449.28695.13562.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/6/2016 5:55 PM, Alan wrote:

> commit d79f16c046086f4fe0d42184a458e187464eb83e fixed a user triggerable

    scripts/checkpatch.pl now enforces certain format of the commit citing.

> scribble on free memory but added a new one which allows the user to
> scribble even more and user controlled data into freed space.
>
> As with 6pack we need to halt the queue before we free the buffers, because
> the transmit logic is not protected by the semaphore.
>
> Signed-off-by: Alan Cox <alan@linux.intel.com>
[...]

MBR, Sergei
