From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Sat, 09 May 2015 23:07:17 +0200
Message-ID: <554E7705.2070707@6wind.com>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com> <874mnn9t12.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tgraf@suug.ch, davem@davemloft.net
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:36572 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbEIVHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:07:20 -0400
Received: by wgiu9 with SMTP id u9so98546576wgi.3
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 14:07:18 -0700 (PDT)
In-Reply-To: <874mnn9t12.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/05/2015 14:02, Eric W. Biederman a =C3=A9crit :
>
> So I am dense.  I have read through the patches and I don't see where
> you tag packets from other network namespaces with a network namespac=
e
> id.
In patch #7, the netns id is put in the skb cb (NETLINK_CB) in the func=
tion
do_one_broadcast().
The function netlink_cmsg_listen_all_nsid() will send this information =
to the
userland via a cmsg data. This function is called by netlink_recvmsg().

> In fact I don't even see an attribute that is approrpriate for such
> tagging.
The netns id is the same attribute that allows to identify a peer netns
via rtnetlink.


Regards,
Nicolas
