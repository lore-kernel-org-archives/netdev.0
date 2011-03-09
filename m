From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Wed, 9 Mar 2011 20:51:18 +0100
Message-ID: <AANLkTinXrZeg31csgbNYph4vQxw_43LrjL+0NFVMhKvH@mail.gmail.com>
References: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
	<AANLkTikFSRr649_P8V8J7Xj_KY8hSEw23RBAyyV2wUQr@mail.gmail.com>
	<AANLkTiknMqNOQKiKpVaDy=zXCXuOxZaQTjKmmxY_bRC5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:53589 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab1CITvT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 14:51:19 -0500
Received: by qwd7 with SMTP id 7so673210qwd.19
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 11:51:18 -0800 (PST)
In-Reply-To: <AANLkTiknMqNOQKiKpVaDy=zXCXuOxZaQTjKmmxY_bRC5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 9 marca 2011 20:18 u=BFytkownik Tom Herbert <therbert@google.com=
> napisa=B3:
>> Please don't add new get/set ops for netdev features - G/SFEATURES
>> handle them all.
>>
>> Proper way is to modify NETIF_F_ETHTOOL_BITS, netdev_fix_features()
>> and, if needed for now,
>> legacy get/set ops (they will go away, eventually).
> Don't see this in
> git://git.kernel.org/pub/scm/network/ethtool/ethtool. =A0Has the patc=
h
> been applied?

This is recent work that just went into net-next. For userspace, if
you want to test it, there is my proof-of-concept patch (posted to
netdev some time ago) or Ben's ethtool cleanup patches (also in netdev
archive).

http://marc.info/?l=3Dlinux-netdev&m=3D129674290420375&w=3D3
http://marc.info/?l=3Dlinux-netdev&m=3D129830729917334&w=3D3

Best Regards,
Micha=B3 Miros=B3aw
