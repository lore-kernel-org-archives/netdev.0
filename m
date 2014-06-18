From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
Date: Wed, 18 Jun 2014 01:40:11 +0000
Message-ID: <4ae893536ee24657ba12043a5f9beabf@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1402993895-10955-1-git-send-email-b38611@freescale.com>
 <20140617163121.GM23430@n2100.arm.linux.org.uk>
 <20140617.153407.622542669190595342.davem@davemloft.net>
 <20140617232151.GO23430@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:49005
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755104AbaFRBkO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2014 21:40:14 -0400
In-Reply-To: <20140617232151.GO23430@n2100.arm.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk> Data: Wednesday, June 18, 2014 7:22 AM
>To: David Miller
>Cc: Duan Fugang-B38611; netdev@vger.kernel.org
>Subject: Re: [PATCH] net: fec: remove HW IP header checksum for IPV6 frame
>
>On Tue, Jun 17, 2014 at 03:34:07PM -0700, David Miller wrote:
>> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
>> Date: Tue, 17 Jun 2014 17:31:21 +0100
>> > As I suspected, just applying the above two hunks fixes the problem
>> > I was seeing.
>>
>> Someone please respin the patch so that it's just these two hunks and
>> that the commit message accurately describes the real situation.
>
>I'm hoping for a reply from Freescale before I give an explicit tested-by
>against this.  It would be nice to have some explicit confirmation that
>they would be happy with a reduced patch.  It may be that the hardware
>really does need the IP header checksum bit cleared for non-IPv4 packets.
>
I test it again that is your expectation HW can detect IPV6 frame type, if it is IPV6 packet,
The IP header checksum function don't take effect. 
I will submit the patch again.
