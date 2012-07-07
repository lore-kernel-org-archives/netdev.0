From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: Question: eth0 and wlan0 traffic load
Date: Sat, 7 Jul 2012 12:55:01 +0800
Message-ID: <CAF1ivSZeqebqDa0NqSKJ9GXb1MW5_36LwKYJdLvsRwNwMuNXiw@mail.gmail.com>
References: <CAF1ivSaY3s-Vjbe7_vziCRCEsaXduug3+2G9R55SUBQ8HPT6hQ@mail.gmail.com>
	<4FF7B826.4010007@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:43242 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab2GGEzi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jul 2012 00:55:38 -0400
Received: from mail-vb0-f46.google.com (mail-vb0-f46.google.com [209.85.212.46])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id C5346DB96D
	for <netdev@vger.kernel.org>; Sat,  7 Jul 2012 12:55:04 +0800 (CST)
Received: by vbbff1 with SMTP id ff1so6544331vbb.19
        for <netdev@vger.kernel.org>; Fri, 06 Jul 2012 21:55:01 -0700 (PDT)
In-Reply-To: <4FF7B826.4010007@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 7, 2012 at 12:16 PM, Ben Greear <greearb@candelatech.com> wrote:
> On 07/06/2012 08:28 PM, Lin Ming wrote:
>>
>> On Host1
>>    eth0: 192.168.1.102
>> wlan0: 192.168.1.103
>>
>> On Host2, scp a file to Host1 via wlan0
>> # scp tmp.file 192.168.1.103:/tmp
>>
>> But ifstat shows all traffic goes to eth0.
>> Why does kernel choose eth0 although I use wlan0's address?
>> Is this an intended behavior?
>
>
> You have to be clever with routing rules, arp-filtering, and such
> to ensure that works as you want.

Ah, right.
The arp cache on Host2 for .102 and .103 points to Host1's eth0.

Host2 # arp -a
chief-river-32.local (192.168.1.102) at 00:1c:c4:a4:33:9e [ether] on eth0
chief-river-32.local (192.168.1.103) at 00:1c:c4:a4:33:9e [ether] on eth0

Thanks,
Lin Ming
