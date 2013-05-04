From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT] 3c59x: fix freeing nonexistent resource on driver
 unload
Date: Sat, 04 May 2013 22:12:46 +0400
Message-ID: <51854F9E.4030703@cogentembedded.com>
References: <201305030110.22462.sergei.shtylyov@cogentembedded.com> <CAP8WD_ZYxhjYag3dQSKnbB6JojV=jxZzmn7_kJW_eOzQOWtKTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tedheadster <tedheadster@gmail.com>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: whiteheadm@acm.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:62292 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761847Ab3EDSNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 May 2013 14:13:12 -0400
Received: by mail-la0-f41.google.com with SMTP id fn20so2351752lab.14
        for <netdev@vger.kernel.org>; Sat, 04 May 2013 11:13:11 -0700 (PDT)
In-Reply-To: <CAP8WD_ZYxhjYag3dQSKnbB6JojV=jxZzmn7_kJW_eOzQOWtKTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03-05-2013 8:26, tedheadster wrote:

> Sergei
>    well, the patch got rid of the "Trying to free nonexistent resource" error.
> However, a problem still persists.

    Does the module at least loads OK for the EISA card now?

> When reloading the module a second time, the system's responsiveness hangs for
> 10s of seconds. It eventually comes back, but even sysrq-h hangs for a long
> time. I was able to do a sysrq-t eventually and capture the output to a log.
> What shall we do to debug this next?

    Frankly speaking, I don't know, and don't have much time to invest in this...

> - Matthew

WBR, Sergei
