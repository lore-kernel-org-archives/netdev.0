From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] netlink: downgrade warning about leftover bytes to debug
 level
Date: Wed, 28 May 2014 09:42:17 +0200
Message-ID: <53859359.70304@6wind.com>
References: <1401196563-6999-1-git-send-email-mschmidt@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Schmidt <mschmidt@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:43601 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbaE1HmV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 03:42:21 -0400
Received: by mail-we0-f171.google.com with SMTP id w62so10649400wes.2
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 00:42:19 -0700 (PDT)
In-Reply-To: <1401196563-6999-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/05/2014 15:16, Michal Schmidt a =C3=A9crit :
> Any process is able to send netlink messages with leftover bytes, so
> downgrade the warning message to pr_debug in order to avoid possible
> kernel log spam.
Yes, but that's not a normal case. I think that the level warning is go=
od,
there is something wrong with this kind of messages.
