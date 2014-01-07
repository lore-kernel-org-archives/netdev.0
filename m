From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC PATCH net-next 1/4] net: introduce backup_classid to struct
 skbuff
Date: Tue, 7 Jan 2014 20:54:03 +0800
Message-ID: <52CBF8EB.6000803@huawei.com>
References: <52C62A48.1050604@huawei.com> <20140103.003404.1439874071277993396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
	<serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	<kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	<lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140103.003404.1439874071277993396.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014/1/3 13:34, David Miller wrote:
> From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Date: Fri, 3 Jan 2014 11:11:04 +0800
> 
>>
>> introduce backup_classid to struct skbuff,
>> we can use it to backup sk_classid when net_ns switch.
>>
>> Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> Sorry, no new sk_buff members unless there is absolutely not other
> possible implementation.
> 

I'm kind of banging my head against the wall with this,
but can not think of a better way.

skb_shared_info is the extension for sk_buffer, how about moving into it?

any comments are appreciated!

thanks,
Libo

> sk_buff is too big as-is.
> 
> .
> 
