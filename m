From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v4] net-next-2.6: Allow ethtool to set interface in
 loopback mode.
Date: Sun, 23 Jan 2011 18:32:12 +0100
Message-ID: <AANLkTinmD26Lwo39v6Veo+EyKhwj7VuF4QbZWVRH2+M3@mail.gmail.com>
References: <1294187401-4662-1-git-send-email-maheshb@google.com>
	<1295655836-23421-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:55451 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab1AWRcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jan 2011 12:32:13 -0500
Received: by qyk12 with SMTP id 12so3686435qyk.19
        for <netdev@vger.kernel.org>; Sun, 23 Jan 2011 09:32:13 -0800 (PST)
In-Reply-To: <1295655836-23421-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/22 Mahesh Bandewar <maheshb@google.com>:
> This patch enables ethtool to set the loopback mode on a given interf=
ace.
> By configuring the interface in loopback mode in conjunction with a p=
olicy
> route / rule, a userland application can stress the egress / ingress =
path
> exposing the flows of the change in progress and potentially help dev=
eloper(s)
> understand the impact of those changes without even sending a packet =
out
> on the network.
[...]

If this is going to be a flag, then maybe you could look at my ethtool
unification
series
http://marc.info/?l=3Dlinux-netdev&m=3D129573447816532&w=3D3
and integrate it there?

On the other hand, if this is going to be driver-specific value, then
you should use ethtool_get_value() and ethtool_set_value() instead of
making yet another copy
(linke eg. ETHTOOL_SMSGLVL).

Best Regards,
Micha=B3 Miros=B3aw
