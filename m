From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 1/2] lib: vsprintf: add IPv4/v6 generic
 %pig/%pIg format specifier
Date: Thu, 27 Jun 2013 01:37:02 +0000 (UTC)
Message-ID: <kqg4vt$1hv$1@ger.gmane.org>
References: <1372266073-11998-1-git-send-email-dborkman@redhat.com>
 <1372266073-11998-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56046 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777Ab3F0BhW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 21:37:22 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Us19E-0000FC-Hh
	for netdev@vger.kernel.org; Thu, 27 Jun 2013 03:37:20 +0200
Received: from 222.221.58.21 ([222.221.58.21])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 03:37:20 +0200
Received: from xiyou.wangcong by 222.221.58.21 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 27 Jun 2013 03:37:20 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jun 2013 at 17:01 GMT, Daniel Borkmann <dborkman@redhat.com> wrote:
> In order to avoid making code that deals with printing both, IPv4 and
> IPv6 addresses, unnecessary complicated as for example ...
>
>   if (sa.sa_family == AF_INET6)
>     printk("... %pI6 ...", sin6_addr);
>   else
>     printk("... %pI4 ...", sin_addr.s_addr);
>

"%pI6c" is more friendly than "%pI6".
