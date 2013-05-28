From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 1/3] net: pass info struct via netdevice
 notifier
Date: Tue, 28 May 2013 11:25:39 +0200
Message-ID: <20130528092539.GA1619@minipsycho.brq.redhat.com>
References: <1369729460-28421-1-git-send-email-jiri@resnulli.us>
 <1369729460-28421-2-git-send-email-jiri@resnulli.us>
 <ko1rc4$nbp$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:41871 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933752Ab3E1JZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 05:25:44 -0400
Received: by mail-ee0-f51.google.com with SMTP id e51so4528240eek.10
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 02:25:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ko1rc4$nbp$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, May 28, 2013 at 10:54:28AM CEST, xiyou.wangcong@gmail.com wrote:
>On Tue, 28 May 2013 at 08:24 GMT, Jiri Pirko <jiri@resnulli.us> wrote:
>>  simeth_device_event(struct notifier_block *this,unsigned long event, void *ptr)
>>  {
>> -	struct net_device *dev = ptr;
>> +	struct net_device *dev = get_netdevice_nofifier_info_dev(ptr);
>
>typo above....

ia64, that's why this passed through my build test :/ Will fix this

>
>BTW, get_netdevice_notifier_info_dev() really sucks, can we make it
>shorter? For example, notifier_into_to_dev()?

I wanted to mention namespace there.
Maybe "netdev_notifier_info_to_dev"

Thanks

>
>Thanks.
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
