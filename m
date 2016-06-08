From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Wed, 8 Jun 2016 18:33:13 +0900
Message-ID: <5757E659.9070501@miraclelinux.com>
References: <1464013425-31129-1-git-send-email-alan.davey@metaswitch.com>
 <20160531.113913.1477085966766110028.davem@davemloft.net>
 <BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
To: Alan Davey <Alan.Davey@metaswitch.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33347 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423745AbcFHJdS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 05:33:18 -0400
Received: by mail-pa0-f41.google.com with SMTP id ec8so967730pac.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 02:33:17 -0700 (PDT)
In-Reply-To: <BN3PR0201MB1059316BEC3EC7F6CBF2F0E4F95E0@BN3PR0201MB1059.namprd02.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Please do not use "top-posting" here.

Alan Davey wrote:
> Hi David
> 
> Thank you for your email.  I understand raw IP sockets have worked this way for a long time, but I think that there is real benefit in this patch for little risk.  Please take a look at the following and let me know what you think.
> 
> -  The current behaviour is counter-intuitive (fragmentation takes place in all other cases) and therefore different to what everyone expects.

I do NEVER expect fragmentation occurs with IP_HDRINCL, at least.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
