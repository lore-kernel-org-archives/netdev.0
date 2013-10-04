From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] veth: Showing peer of veth type dev in ip link (kernel
 side)
Date: Fri, 04 Oct 2013 17:21:33 +0200
Message-ID: <524EDCFD.9070204@6wind.com>
References: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Masatake YAMATO <yamato@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:36738 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721Ab3JDPVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 11:21:36 -0400
Received: by mail-wg0-f52.google.com with SMTP id m15so4271945wgh.31
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 08:21:35 -0700 (PDT)
In-Reply-To: <1380859529-32351-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/10/2013 06:05, Masatake YAMATO a =C3=A9crit :
> ip link has ability to show extra information of net work device if
> kernel provides sunh information. With this patch veth driver can
> provide its peer ifindex information to ip command via netlink
> interface.
But the ifindex can be interpreted only when you know the related netns=
 and
veth peer is probably in another netns.
How to found the netdevice in userland in this case?
