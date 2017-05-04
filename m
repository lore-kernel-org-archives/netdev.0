From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH] aquantia: Fix "ethtool -S" crash when adapter down.
Date: Thu, 4 May 2017 21:08:06 +0200
Message-ID: <37304a98-c122-c360-882b-31db3f62c1bf@gmx.de>
References: <90666578f043b366313ddd90ffad86de42d890f2.1493914743.git.pavel.belous@aquantia.com>
 <0babf800-080c-96e0-4dbb-8d3fca3fb784@gmx.de>
 <20170504.125113.569969253752966231.davem@davemloft.net>
 <d20deac6-7010-c0e8-e4d8-7faa591e7306@aquantia.com>
 <0efef5aa-c73d-ff16-a2ec-e63ad298ffa2@redhat.com>
 <b039f869-2b3a-416f-2f52-f3efdf7b385a@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pavel Belous <pavel.belous@aquantia.com>,
        David Arcari <darcari@redhat.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:59916 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754514AbdEDTI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 15:08:28 -0400
In-Reply-To: <b039f869-2b3a-416f-2f52-f3efdf7b385a@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04.05.2017 20:37, Pavel Belous wrote:

> 
> Yes, even adapter is in the down state user can still see statistics from the HW.
> For example (adapter is down):
> 
> $ ethtool -S enp2s0
> NIC statistics:
>      InPackets: 3237727
>      InUCast: 3237214
>      InMCast: 391
>      InBCast: 122
>      InErrors: 0
>      OutPackets: 14157898
>      OutUCast: 14157089
>      OutMCast: 304
>      OutBCast: 505
>      InUCastOctects: 226714406
>      OutUCastOctects: 10463156
>      InMCastOctects: 58046
>      OutMCastOctects: 44817
>      InBCastOctects: 12857
>      OutBCastOctects: 41626
>      InOctects: 226785309
>      OutOctects: 10549599
>      InPacketsDma: 0
>      OutPacketsDma: 16
>      InOctetsDma: 0
>      OutOctetsDma: 2396
>      InDroppedDma: 0
>      Queue[0] InPackets: 0
>      Queue[0] OutPackets: 0
>      Queue[0] InJumboPackets: 0
>      Queue[0] InLroPackets: 0
>      Queue[0] InErrors: 0
>      Queue[1] InPackets: 0
>      Queue[1] OutPackets: 0
>      Queue[1] InJumboPackets: 0
>      Queue[1] InLroPackets: 0
>      Queue[1] InErrors: 0
>      Queue[2] InPackets: 0
>      Queue[2] OutPackets: 0
>      Queue[2] InJumboPackets: 0
>      Queue[2] InLroPackets: 0
>      Queue[2] InErrors: 0
>      Queue[3] InPackets: 0
>      Queue[3] OutPackets: 0
>      Queue[3] InJumboPackets: 0
>      Queue[3] InLroPackets: 0
>      Queue[3] InErrors: 0
> 
> Lino, David what do you think?
> If you agree I can re-submit the patch (with fixed braces).
> 

Well my objection was related to how the bug is fixed. If in the end we have a solution
as suggested by David it would be even better, of course. I dont think that this is too
hard to realize since it is only the queues stats that are missing. But if you prefer to 
solve it in two steps, sure, no objections from my side :)

Regards,
Lino 
