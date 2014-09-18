From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Figuring out how vti works
Date: Thu, 18 Sep 2014 11:06:23 +0200
Message-ID: <20140918090623.GU6390@secunet.com>
References: <20140915142043.GA22070@master>
 <20140917052811.GT6390@secunet.com>
 <CAHjjW16qdT6RWuJaUd1c6k39RgcPtfsyF=V-dVowW_2UwhF_dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe M <joe9mail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41936 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753540AbaIRJGh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 05:06:37 -0400
Content-Disposition: inline
In-Reply-To: <CAHjjW16qdT6RWuJaUd1c6k39RgcPtfsyF=V-dVowW_2UwhF_dw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 06:04:07PM -0500, Joe M wrote:
> 
> master# echo "1" | sudo tee /proc/sys/net/ipv4/ip_forward
> 1
> master# modprobe ip_vti
> master# ipsec start
> Starting strongSwan 5.2.0 IPsec [starter]...
> master# ip tunnel add vtil mode vti local 192.168.0.11 remote
> 192.168.1.232 ikey 1 okey 1
> master# ip link set vtil up
> master# sleep 60
> master# ip route add 192.168.1.0/24 dev vtil
> master# ip xfrm state
> src 192.168.0.11 dst <client or alice or bnglr public ip>

Not sure what <client or alice or bnglr public ip> is,
but dst must match the remote tunnel endpoint i.e.
192.168.1.232 in your case.
