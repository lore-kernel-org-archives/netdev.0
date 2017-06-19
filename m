From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: add new T6 pci device id's
Date: Mon, 19 Jun 2017 09:57:23 +0000
Message-ID: <CY4PR12MB1432768B2930D10BFA54E343C1C40@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <1497855249-7173-1-git-send-email-ganeshgr@chelsio.com>,<912f67f7-0bee-b4f4-73c6-6eebf80652cf@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Nirranjan Kirubaharan <nirranjan@chelsio.com>,
        Indranil Choudhury <indranil@chelsio.com>,
        Venkatesh Pottem <venkatesh@chelsio.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0103.outbound.protection.outlook.com ([104.47.36.103]:58684
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753936AbdFSJ50 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 05:57:26 -0400
In-Reply-To: <912f67f7-0bee-b4f4-73c6-6eebf80652cf@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks, I will send a V2.





From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Sent: Monday, June 19, 2017 3:18 PM
To: Ganesh GR; netdev@vger.kernel.org; davem@davemloft.net
Cc: Nirranjan Kirubaharan; Indranil Choudhury; Venkatesh Pottem
Subject: Re: [PATCH net-next] cxgb4: add new T6 pci device id's
=A0  =20
Hello!

On 6/19/2017 9:54 AM, Ganesh Goudar wrote:

> Add 0x6081, 0x6082 and 0x6083 T6 device id's

=A0=A0=A0 0x6081 is already there, you're adding 0x6084 instead.

> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> ---
>=A0 drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h | 3 +++
>=A0 1 file changed, 3 insertions(+)
>
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h b/drivers=
/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> index be7041f..99987d8 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> +++ b/drivers/net/ethernet/chelsio/cxgb4/t4_pci_id_tbl.h
> @@ -192,6 +192,9 @@ CH_PCI_DEVICE_ID_TABLE_DEFINE_BEGIN
>=A0=A0=A0=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6015),
>=A0=A0=A0=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6080),
>=A0=A0=A0=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6081),
> +=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6082), /* Custom T6225-CR SFP28 */
> +=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6083), /* Custom T62100-CR QSFP28 =
*/
> +=A0=A0=A0=A0 CH_PCI_ID_TABLE_FENTRY(0x6084), /* Custom T64100-CR QSFP28 =
*/
>=A0 CH_PCI_DEVICE_ID_TABLE_DEFINE_END;
>
>=A0 #endif /* __T4_PCI_ID_TBL_H__ */

MBR, Sergei

    =
