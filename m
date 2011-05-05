From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/2] net: use NETIF_F_ALL_TSO for vlan features
Date: Thu, 5 May 2011 20:19:05 +0200
Message-ID: <BANLkTikLq909D9Dy7cfQRmgXoOiH11cQhA@mail.gmail.com>
References: <4DBA4AB4.5000802@cn.fujitsu.com> <20110505.105350.183065364.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shanwei@cn.fujitsu.com, netdev@vger.kernel.org,
	eilong@broadcom.com, dm@chelsio.com, leedom@chelsio.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48761 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755667Ab1EESTZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 14:19:25 -0400
Received: by qyk7 with SMTP id 7so3729358qyk.19
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 11:19:25 -0700 (PDT)
In-Reply-To: <20110505.105350.183065364.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/5 David Miller <davem@davemloft.net>:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Fri, 29 Apr 2011 13:20:52 +0800
>> As Dimitris Michailidis suggested, use NETIF_F_ALL_TSO for vlan_feat=
ures,
>> which is a mask, but not hw_features.
> I do not understand why we want to advertise a set of ->vlan_features
> TSO flags that are different from the flags advertised in ->hw_featur=
es.
>
> Why do we want to do this?

I remember some posts about hardware that needs HW tag insertion for
TSO on VLAN to work or other additional constraints for offloads on
VLANs. I wonder if vlan_features handling should be converted to
something like ndo_fix_features.

Best Regards,
Micha=B3 Miros=B3aw
