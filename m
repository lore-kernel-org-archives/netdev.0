From: Bharat Kumar Gogada <bharat.kumar.gogada@xilinx.com>
Subject: RE: [PATCH] rtlwifi: rtl8192x: Enabling and disabling hardware
 interrupts after enabling local irq flags
Date: Fri, 20 Jan 2017 14:14:10 +0000
Message-ID: <8520D5D51A55D047800579B094147198263CA86D@XAP-PVEXMBX02.xlnx.xilinx.com>
References: <1484820854-16719-1-git-send-email-bharatku@xilinx.com>
 <b2e783f6-fa09-e287-8119-266299cdae22@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Ravikiran Gummaluri <rgummal@xilinx.com>
To: Larry Finger <Larry.Finger@lwfinger.net>,
        "chaoming_li@realsil.com.cn" <chaoming_li@realsil.com.cn>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0089.outbound.protection.outlook.com ([104.47.36.89]:61733
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752422AbdATOOY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 09:14:24 -0500
In-Reply-To: <b2e783f6-fa09-e287-8119-266299cdae22@lwfinger.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 > On 01/19/2017 04:14 AM, Bharat Kumar Gogada wrote:
> > -Realtek 8192CE chipset maintains local irq flags after enabling/disabl=
ing
> > hardware interrupts.
> > -Hardware interrupts are enabled before enabling the local irq
> > flags(these flags are being checked in interrupt handler),
> > leading to race condition on some RP, where the irq line between
> > bridge and GIC goes high at ASSERT_INTx and goes low only
> > at DEASSERT_INTx. In this kind of RP by the time ASSERT_INTx is seen
> > irq_enable flag is still set to false, resulting in continuous
> > interrupts seen by CPU as DEASSERT_INTx cannot be sent since
> > flag is still false and making CPU stall.
> > -Changing the sequence of setting these irq flags.
> >
> > Signed-off-by: Bharat Kumar Gogada <bharatku@xilinx.com>
> > ---
>=20
> This patch should be enhanced with the smb_xx() calls as suggested by by =
Lino.
>=20
> The subject should be changed. I would suggest something like "rtlwifi:
> rtl8192ce: Prevent race condition when enabling interrupts", as it explai=
ns the
> condition you are preventing.
>=20
> The other PCI drivers also have the same problem. Do you want to prepare =
the
> patches, or should I do it?
>=20
Thanks Larry. Please send out the patches adding the above enhancements sug=
gested by Lino.

Bharat
