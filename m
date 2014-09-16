From: Michael Chan <mchan@broadcom.com>
Subject: Re: tg3 issue with tcp checksums and vlan packets
Date: Tue, 16 Sep 2014 09:54:35 -0700
Message-ID: <1410886475.7520.73.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <541868A9.7080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:27831 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaIPQyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 12:54:36 -0400
In-Reply-To: <541868A9.7080407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-16 at 12:43 -0400, Vlad Yasevich wrote: 
> Prashant and Michael
> 
> I am seeing a strange issue with tg3 driver when I try to pass to it tcp packets
> that have partial checksums and inline (non-accelerated) vlan header.
> 

Are you disabling NETIF_F_HW_VLAN_CTAG_TX?  I believe TX checksum and
TSO won't work.  We need to add some code to disable both when VLAN
acceleration is disabled.
