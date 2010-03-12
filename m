From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 5/6] smsc95xx: check return code from control messages
Date: Fri, 12 Mar 2010 13:32:07 +0000
Message-ID: <OF7F698D80.1B37FCB1-ON802576E4.004A3343-802576E4.004A6117@smsc.com>
References: <1268245959-13861-6-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:58052 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753346Ab0CLNcJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 08:32:09 -0500
Received: from mta.smsc.com (mta [170.129.83.113])
	by internal.smsc.com (8.14.3/8.14.3) with ESMTP id o2CDW7Hk020855
	for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 08:32:07 -0500
In-Reply-To: <1268245959-13861-6-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define check_warn(ret, fmt, args...) \
> +   ({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
> +
> +#define check_warn_return(ret, format, args...) \
> +   ({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); return ret; } 
})
> +
> +#define check_warn_goto_done(ret, format, args...) \
> +   ({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); goto done; } 
})
> +

Apologies, this patch is broken.

Please do not apply this anywhere, I'll send a replacement patch shortly.

Steve
