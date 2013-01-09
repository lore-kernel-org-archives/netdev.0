From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] ipv6: Netlink notify forwarding change
Date: Wed, 09 Jan 2013 17:27:52 +0100
Message-ID: <50ED9A88.1060308@6wind.com>
References: <20130109001114.GA3393@debian-saurabh-64.vyatta.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Saurabh Mohan <saurabh.mohan@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:44767 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755071Ab3AIQ14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 11:27:56 -0500
Received: by mail-bk0-f47.google.com with SMTP id j4so1026360bkw.34
        for <netdev@vger.kernel.org>; Wed, 09 Jan 2013 08:27:55 -0800 (PST)
In-Reply-To: <20130109001114.GA3393@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/01/2013 01:11, Saurabh Mohan a =E9crit :
>
>
> If the interface is up and the forwarding attribute
> (net.ipv6.conf.eth1.forwarding) is changed then a netlink message is =
not
> generated.
>
A rtnetlink message RTM_NEWNETCONF is sent (see inet6_netconf_notify_de=
vconf()).
