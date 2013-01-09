From: Saurabh Mohan <saurabh.mohan@vyatta.com>
Subject: Re: [PATCH] ipv6: Netlink notify forwarding change
Date: Wed, 09 Jan 2013 10:55:30 -0800 (PST)
Message-ID: <c3817b6c-14c8-4450-b2bb-43480170611c@tahiti.vyatta.com>
References: <50ED9A88.1060308@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nicolas dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40469 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932487Ab3AISzc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 13:55:32 -0500
In-Reply-To: <50ED9A88.1060308@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message -----
> Le 09/01/2013 01:11, Saurabh Mohan a =C3=A9crit :
> >
> >
> > If the interface is up and the forwarding attribute
> > (net.ipv6.conf.eth1.forwarding) is changed then a netlink message
> > is not
> > generated.
> >
> A rtnetlink message RTM_NEWNETCONF is sent (see
> inet6_netconf_notify_devconf()).

yes. The submitted patch is invalid with the
latest version. Thanks.
