From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 1/4] kernel: time: Add current_nw_timestamp() for network
 timestamps
Date: Fri, 26 Feb 2016 15:49:05 +0900
Message-ID: <56CFF561.4050805@miraclelinux.com>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
 <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
 <56CEC010.1080506@miraclelinux.com>
 <CABeXuvpzFzj094YKhweoCO+BUaxGAP+dYjPZozA01z94=gVaMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Linux Network Devel Mailing List <netdev@vger.kernel.org>,
	y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33247 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbcBZGtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 01:49:14 -0500
Received: by mail-pf0-f169.google.com with SMTP id q63so47000338pfb.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 22:49:14 -0800 (PST)
In-Reply-To: <CABeXuvpzFzj094YKhweoCO+BUaxGAP+dYjPZozA01z94=gVaMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Deepa Dinamani wrote:
>>>  include/linux/ip.h     |  2 ++
>>>  include/linux/time64.h |  3 +++
>>>  kernel/time/time.c     | 26 ++++++++++++++++++++++++++
>>>  3 files changed, 31 insertions(+)
>>>
>> Since net/ipv4/* are the only users, it is enough to put
>> it in under net/ipv4/.
> 
> time.c hosts functions that are used by individual subsystems like
> current_fs_time() used by filesystems
> (sometimes used by other subsystems also).
> 
> The network timestamp function is used for both source route ip option
> and timestamp icmp messages.
> So it makes it difficult for it to be owned by a single layer.
> This is the reason it was chosen to include here.
> 
> Another option is to include it in the lowest layer its used:
> af_inet.c. Is this what you were suggesting?
> 

Yes, that's right.

--yoshfuji

> -Deepa
> 
