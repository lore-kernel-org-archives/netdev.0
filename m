From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: RE: [net-next] net: remove duplicate add_device_randomness() call
Date: Fri, 5 May 2017 10:40:02 +0800
Message-ID: <003901d2c548$e5c49ab0$b14dd010$@cmss.chinamobile.com>
References: <1493869242-65468-1-git-send-email-zhangshengju@cmss.chinamobile.com> <20170504.111302.1520073128399942830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <edumazet@google.com>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:42002 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754358AbdEECkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 22:40:13 -0400
In-Reply-To: <20170504.111302.1520073128399942830.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 04, 2017 11:13 PM
> To: zhangshengju@cmss.chinamobile.com
> Cc: netdev@vger.kernel.org; edumazet@google.com
> Subject: Re: [net-next] net: remove duplicate add_device_randomness() call
> 
> From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Date: Thu,  4 May 2017 11:40:42 +0800
> 
> > Since register_netdevice() already call add_device_randomness() and
> > dev_set_mac_address() will call it after mac address change.
> > It's not necessary to call at device UP.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> 
> The net-next tree is closed, please resubmit this when the net-next tree
> opens back up.

Okay, thanks David.

BRs,
ZSJ
