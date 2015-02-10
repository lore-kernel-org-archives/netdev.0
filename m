From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH next 4/6] bonding: Allow userspace to set system_priority
Date: Mon, 09 Feb 2015 23:05:17 -0800
Message-ID: <28432.1423551917@famine>
References: <1423270314-9271-1-git-send-email-maheshb@google.com> <20150207033847.GD34197@gospo.home.greyhouse.net> <6873.1423289974@famine> <CAF2d9ji-m6Suw_Rw6dBqs=Ky41h786rCrPh-J7tv7JA+4L84zw@mail.gmail.com> <13353.1423381584@famine> <CAF2d9jhkSD+EyHLzJSjS9rXdDCSfEQyFD5X9-D9KmGPFeu2RWA@mail.gmail.com>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36452 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbbBJHF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 02:05:28 -0500
In-reply-to: <CAF2d9jhkSD+EyHLzJSjS9rXdDCSfEQyFD5X9-D9KmGPFeu2RWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mahesh Bandewar <maheshb@google.com> wrote:
[...]
>Actually I was thinking of making ad_actor_sysprio instead of making
>ad_user_port_key (feels like having more underscores makes it
>unnecessary longer). That way all three look similar. So
>
>         ad_actor_sysprio
>         ad_actor_system
>         ad_user_portkey
>
>All carry the same theme of meaning. Otherwise we could do something like -
>
>         ad_actor_sys_prio
>         ad_actor_sys_mac
>         ad_user_port_key
>
>Which one seems more logical / reasonable?

	FWIW, I would go with ad_actor_sys_prio, ad_actor_system and
ad_user_port_key.  The first two then mimic the terms from the standard,
and the "user" one is part of the Actor_Admin_Port_Key from the
standard, so it follows the same sort of naming.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
