From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: "NIG timer max" messages from bnx2x
Date: Thu, 3 Dec 2009 09:47:22 +0200
Message-ID: <1259826442.15524.2.camel@lb-tlvb-eilong>
References: <4B168F04.60309@redpill-linpro.com>
 <1259779263.2020.6.camel@lb-tlvb-eilong>
 <4B176A86.30009@redpill-linpro.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>
To: "Tore Anderson" <tore.anderson@redpill-linpro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4170 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbZLCHrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 02:47:13 -0500
In-Reply-To: <4B176A86.30009@redpill-linpro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-12-02 at 23:36 -0800, Tore Anderson wrote:
> However I'm still a bit confused on why this is triggering the "NIG
> timer max" message on the Linux blade.  It would have made perfect sense
> to me for the bnx2x driver/NIC to stop transmitting outbound frames if
> it was the recipient of an inbound pause frame flood, but tcpdump does
> not show any such frames being received.  Yet it stalls all outbound
> traffic.  Any idea why?
> 
The pause frames are processed in the HW and therefore not visible to
tcpdump. You should be able to see the pause counter increases in
"ethtool -S".

Regards,
Eilon


