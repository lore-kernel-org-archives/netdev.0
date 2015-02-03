From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 03 Feb 2015 15:02:07 +0100
Message-ID: <54D0D4DF.7080906@6wind.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com> <54CA0B9F.8080104@6wind.com> <20150202084443.GS13046@secunet.com> <54CF3D3A.5040607@6wind.com> <20150203122432.GV13046@secunet.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, herbert@gondor.apana.org.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:44932 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753210AbbBCOCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 09:02:12 -0500
Received: by mail-we0-f175.google.com with SMTP id p10so45207782wes.6
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 06:02:11 -0800 (PST)
In-Reply-To: <20150203122432.GV13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 03/02/2015 13:24, Steffen Klassert a =E9crit :
> On Mon, Feb 02, 2015 at 10:02:50AM +0100, Nicolas Dichtel wrote:
>
> I tend to apply this patch unless you can come up with a real world
> application that will break if we do so.
It's a custom patch made for strongswan (not included upstream).

My suggestion was to display an error message instead of rejecting the =
message.
But fair enough, let's apply this patch, it will force people to come u=
p with a
proper solution.
