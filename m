From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH v2 0/2] tg3:  Fix handling of non-acceleration vlans
Date: Fri, 19 Sep 2014 17:39:46 -0700
Message-ID: <1411173586.6401.39.camel@prashant>
References: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Vladislav Yasevich <vyasevic@redhat.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:44205 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756392AbaITAtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 20:49:47 -0400
In-Reply-To: <1411165389-21276-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 18:23 -0400, Vladislav Yasevich wrote:
> TG3 can't cope with checksum and TSO offloads when vlan headers were
> not accelerated.  This can be demonstrated with 802.1ad vlans or
> by configuring a vlan on top of a bridge and turning off vlan acceleration
> on the bridge device.
> 
> Instead of disabling all vlan acceleration, this series works around
> the issue by having tg3 driver call software segmentation and checksum
> generation.
> 
> v2: - moved the call to software segment soonner
>     - Preserve the checksum flags for TSO/LSO case and turn it off
>       if software checksum was computed.
>     - Add code to correctly receive full sized 802.1ad frames.
> 
> Vladislav Yasevich (2):
>   tg3: Work around HW/FW limitations with vlan encapsulated frames
>   tg3: Allow for receive of full-size 8021AD frames
> 
>  drivers/net/ethernet/broadcom/tg3.c | 21 ++++++++++++++++++++-
>  1 file changed, 20 insertions(+), 1 deletion(-)
> 
Acked-by: Prashant Sreedharan <prashant@broadcom.com>
