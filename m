From: Gilberto <gilberto.bertin@gmail.com>
Subject: Re: [net-next RFC 0/4] SO_BINDTOSUBNET
Date: Fri, 25 Mar 2016 22:29:07 +0000
Message-ID: <56F5BBB3.4010706@gmail.com>
References: <1458134349-2454-1-git-send-email-gilberto.bertin@gmail.com>
 <CALx6S35+Lv85SQvqMOe4anj6z=qXB+5dUjhEw1x=jQRQGLjD2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37348 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597AbcCYW3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 18:29:11 -0400
Received: by mail-wm0-f43.google.com with SMTP id p65so36010666wmp.0
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 15:29:10 -0700 (PDT)
In-Reply-To: <CALx6S35+Lv85SQvqMOe4anj6z=qXB+5dUjhEw1x=jQRQGLjD2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/25/2016 12:25 AM, Tom Herbert wrote:
> On Wed, Mar 16, 2016 at 6:19 AM, Gilberto Bertin
> <gilberto.bertin@gmail.com> wrote:
>> This is my second attempt to submit an RFC for this patch.
>>
>> Some arguments for and against it since the first submission:
>> * SO_BINDTOSUBNET is an arbitrary option and can be seens as nother use
>> * case of the SO_REUSEPORT BPF patch
>> * but at the same time using BPF requires more work/code on the server
>>   and since the bind to subnet use case could potentially become a
>>   common one maybe there is some value in having it as an option instead
>>   of having to code (either manually or with clang) an eBPF program that
>>   would do the same
> 
> Gilberto, I'm not sure I understand this argument. Have you
> implemented the BPF bind solution?
> 
> Thanks,
> Tom

Yes, I wrote up a very basic draft for this feature (I didn't know there
was already some work going on with SO_ATTACH_REUSEPORT_[CE]BPF).

Thanks,
Gilberto
