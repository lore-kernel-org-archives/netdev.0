From: "Ian Brown" <ianbrn@gmail.com>
Subject: cleanup suggestion of 5 fields
Date: Sun, 6 May 2007 17:54:32 +0300
Message-ID: <d0383f90705060754l1e738013y4cd9205ade0c3e9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:45318 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645AbXEFOyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 10:54:33 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1305874nzf
        for <netdev@vger.kernel.org>; Sun, 06 May 2007 07:54:33 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

It seems to me that the following fields should be cleaned up as except the
definition, they do not appear anywhere in the kernel code:

a) since FASTROUTE is no longer used:

in include/linux/if_packet.h:
#define PACKET_FASTROUTE        6               /* Fastrouted frame     */
in include/linux/if_wanpipe.h:
#define WAN_PACKET_FASTROUTE	6		/* Fastrouted frame	*/

b) and (not conncected to removal of FASTROUTE)
in include/linux/if_arp.h
#define	ARPOP_InREQUEST	8		/* InARP request		*/
#define	ARPOP_InREPLY	9		/* InARP reply			*/
#define	ARPOP_NAK	10		/* (ATM)ARP NAK			*/

Regards,
Ian
