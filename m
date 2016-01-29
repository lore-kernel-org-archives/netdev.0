From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH v2 net] nfc: use GFP_USER for user-controlled kmalloc
Date: Sat, 30 Jan 2016 09:01:56 +1100
Message-ID: <CAGRGNgW16nQrvuePehmiirLxJpO-Oatd6iMP_tXQfu8JjmoVnA@mail.gmail.com>
References: <1454095465-16685-1-git-send-email-xiyou.wangcong@gmail.com> <1454096764.7627.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36098 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757040AbcA2WCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:02:16 -0500
In-Reply-To: <1454096764.7627.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Cong

On Sat, Jan 30, 2016 at 6:46 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-01-29 at 11:24 -0800, Cong Wang wrote:
>> These two functions are called in sendmsg path, and the
>> 'len' is passed from user-space, so we should not allow
>> malicious users to OOM kernel on purpose.
>>
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
>> Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
>> Cc: Samuel Ortiz <sameo@linux.intel.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>> ---
>
> Note that the issue is not OOM the kernel (as the allocation is
> attempted even after your patch), but having a way to
> spill stack traces in the syslog.
>
> Acked-by: Eric Dumazet <edumazet@google.com>

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
