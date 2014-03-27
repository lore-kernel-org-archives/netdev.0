From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] dev: ensure that dellink is set before calling
 it
Date: Thu, 27 Mar 2014 14:27:00 +0100
Message-ID: <53342724.9030005@6wind.com>
References: <1395925862-19354-1-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:57252 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775AbaC0N1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 09:27:04 -0400
Received: by mail-we0-f169.google.com with SMTP id w62so1795340wes.14
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:27:01 -0700 (PDT)
In-Reply-To: <1395925862-19354-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/03/2014 14:11, Nicolas Dichtel a =C3=A9crit :
> default_device_exit_batch() was calling it as soon as dev->rtnl_link_=
ops was
> set.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Please, drop this patch. I just notice that rtnl_link_register() ensure=
s that
dellink is set.

Sorry for the noise.
