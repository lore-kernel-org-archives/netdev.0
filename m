From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: epoll broken [was: mmotm 2011-01-25-15-47 uploaded]
Date: Thu, 03 Feb 2011 10:03:53 +0100
Message-ID: <4D4A6F79.4070502@gmail.com>
References: <201101260021.p0Q0LxsS016458@imap1.linux-foundation.org>	 <4D4A5BBF.20806@gmail.com> <1296719601.3438.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
	davidel@xmailserver.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296719601.3438.0.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2011 08:53 AM, Eric Dumazet wrote:
>> {0, {u32=0, u64=0}} .............. {0, {u32=0, u64=0}}, ?}
>> 0x7fb816996660, 8192, 0) = 379151968
>> 17836 --- SIGSEGV (Segmentation fault) @ 0 (0) ---
>> 17836 +++ killed by SIGSEGV +++
>>
>> The parameter, the same as the retval, seems to be bogus.
>>
>> Is it known (fixed in newer kernels)?
>>
>> thanks,
> 
> Yes, its known, and a fix is there : https://lkml.org/lkml/2011/1/26/121

Thanks, it works indeed.

-- 
js
