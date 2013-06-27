From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic %pig/%pIg
 format specifier
Date: Thu, 27 Jun 2013 09:47:57 +0200
Message-ID: <51CBEE2D.1080209@redhat.com>
References: <1372266073-11998-1-git-send-email-dborkman@redhat.com> <1372266073-11998-2-git-send-email-dborkman@redhat.com> <kqg4vt$1hv$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35305 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751241Ab3F0HsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jun 2013 03:48:00 -0400
In-Reply-To: <kqg4vt$1hv$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2013 03:37 AM, Cong Wang wrote:
> On Wed, 26 Jun 2013 at 17:01 GMT, Daniel Borkmann <dborkman@redhat.com> wrote:
>> In order to avoid making code that deals with printing both, IPv4 and
>> IPv6 addresses, unnecessary complicated as for example ...
>>
>>    if (sa.sa_family == AF_INET6)
>>      printk("... %pI6 ...", sin6_addr);
>>    else
>>      printk("... %pI4 ...", sin_addr.s_addr);
>>
>
> "%pI6c" is more friendly than "%pI6".

Sure, but that was just an example as stated above.
