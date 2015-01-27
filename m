From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 1/2] caif: remove wrong dev_net_set() call
Date: Tue, 27 Jan 2015 12:34:40 +0100
Message-ID: <54C777D0.6090608@6wind.com>
References: <1422307694-10079-1-git-send-email-nicolas.dichtel@6wind.com> <1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, dmitry.tarnyagin@lockless.no,
	arvid.brodin@alten.se, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org,
	=?UTF-8?B?U2p1ciBCcsOmbmRlbGFuZA==?=
	<sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:53751 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758228AbbA0Leo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 06:34:44 -0500
Received: by mail-wi0-f176.google.com with SMTP id em10so4089432wid.3
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 03:34:42 -0800 (PST)
In-Reply-To: <1422307694-10079-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/01/2015 22:28, Nicolas Dichtel a =C3=A9crit :
> src_net points to the netns where the netlink message has been receiv=
ed. This
> netns may be different from the netns where the interface is created =
(because
> the user may add IFLA_NET_NS_[PID|FD]). In this case, src_net is the =
link netns.
>
> It seems wrong to override the netns in the newlink() handler because=
 if it
> was not already src_net, it means that the user explicitly asks to cr=
eate the
> netdevice in another netns.
>
> CC: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
> CC: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>

I got a "Delivery Status Notification (Failure)" for Dmitry Tarnyagin (=
I took=20
the email address from the MAINTAINERS file):

   Delivery to the following recipient failed permanently:

        dmitry.tarnyagin@lockless.no

   Technical details of permanent failure:
   Google tried to deliver your message, but it was rejected by the ser=
ver for
   the recipient domain lockless.no by mail.lockless.no. [46.29.221.38]=
=2E

   The error that the other server returned was:
   550 5.1.1 <dmitry.tarnyagin@lockless.no>: Recipient address rejected=
: User
   unknown in virtual mailbox table

Any suggestions?
