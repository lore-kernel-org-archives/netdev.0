From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Wed, 9 Mar 2011 11:18:41 -0800
Message-ID: <AANLkTiknMqNOQKiKpVaDy=zXCXuOxZaQTjKmmxY_bRC5@mail.gmail.com>
References: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
	<AANLkTikFSRr649_P8V8J7Xj_KY8hSEw23RBAyyV2wUQr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:3255 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1CITSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 14:18:50 -0500
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p29JImtS023874
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 11:18:48 -0800
Received: from yxh35 (yxh35.prod.google.com [10.190.2.227])
	by kpbe20.cbf.corp.google.com with ESMTP id p29JIDIJ020827
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 9 Mar 2011 11:18:46 -0800
Received: by yxh35 with SMTP id 35so423683yxh.16
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2011 11:18:42 -0800 (PST)
In-Reply-To: <AANLkTikFSRr649_P8V8J7Xj_KY8hSEw23RBAyyV2wUQr@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Please don't add new get/set ops for netdev features - G/SFEATURES
> handle them all.
>
> Proper way is to modify NETIF_F_ETHTOOL_BITS, netdev_fix_features()
> and, if needed for now,
> legacy get/set ops (they will go away, eventually).
>

Don't see this in
git://git.kernel.org/pub/scm/network/ethtool/ethtool.  Has the patch
been applied?

Tom
