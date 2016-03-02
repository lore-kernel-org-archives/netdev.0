From: Ariel Elior <Ariel.Elior@qlogic.com>
Subject: RE: [PATCH net 0/7] bnx2x: endianness fixes
Date: Wed, 2 Mar 2016 13:45:57 +0000
Message-ID: <CY1PR11MB08288B7F524EB18F719A36688ABC0@CY1PR11MB0828.namprd11.prod.outlook.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Michal Schmidt <mschmidt@redhat.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0134.outbound.protection.outlook.com ([207.46.100.134]:51650
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751682AbcCBPUQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 10:20:16 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Michal Schmidt [mailto:mschmidt@redhat.com]
> Sent: Wednesday, March 02, 2016 2:47 PM
> To: netdev <netdev@vger.kernel.org>
> Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>; Ariel Elior <Ariel.Elior@qlogic.com>
> Subject: [PATCH net 0/7] bnx2x: endianness fixes
> 
> Hello,
> this fixes a VLAN crash and some SRIOV bugs in bnx2x observed on ppc64.
> 
> Michal Schmidt (7):
>   bnx2x: fix crash on big-endian when adding VLAN
>   bnx2x: fix sending VF->PF messages on big-endian
>   bnx2x: fix receive of VF->PF mailbox messages by the PF on big-endian
>   bnx2x: access cfc_del_event only if the opcode is CFC_DEL
>   bnx2x: define fields of struct cfc_del_event_data as little-endian
>   bnx2x: define event data reserved fields as little-endian
>   bnx2x: fix indentation in bnx2x_sp_task()
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h   | 36 ++++++++++-------------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  | 22 +++++++-------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c | 12 ++++----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |  4 +--
>  4 files changed, 32 insertions(+), 42 deletions(-)
> 
> --
> 2.5.0
Hi Michal,
Thanks for making these changes!
Acked-By: Ariel Elior <Ariel.Elior@qlogic.com>
