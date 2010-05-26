From: Rahul Gundecha <rahul.gundecha@gmail.com>
Subject: Fwd: why the number of queue of NIC impact the ping results?
Date: Wed, 26 May 2010 16:46:59 +0530
Message-ID: <AANLkTil1vLvEcA6MbiamYVRZbGpPh-I8sza0WHOX69hr@mail.gmail.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2498091D21@MILEXCH2.ds.jdsu.net>
	<AANLkTil27c_dBP0hgcEMSCUNakyU-4kc4_0ATw2gt2eT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Zhou <Jon.Zhou@jdsu.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:33053 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab0EZLRT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 07:17:19 -0400
Received: by pvg3 with SMTP id 3so1042200pvg.19
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 04:17:19 -0700 (PDT)
In-Reply-To: <AANLkTil27c_dBP0hgcEMSCUNakyU-4kc4_0ATw2gt2eT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What is the driver version you are using?=A0 Is it 1.45.21, the one
present in 2.6.27-19 ?
Upgrading the whole kernel to latest version would be helpful for multi=
-queue.

On Wed, May 26, 2010 at 2:31 PM, Jon Zhou <Jon.Zhou@jdsu.com> wrote:
>
> broadcom bnx2x netxtreme2-5.2.50,kernel 2.6.27-19
>
> @receiver:
>
> insmod ./bnx2x.ko =A0multi_mode=3D1 num_queues=3D12/14/16
>
> @sender:
> ping receiver ->response OK
>
>
> but no response when
>
> insmod ./bnx2x.ko =A0multi_mode=3D1 num_queues=3D2/4/8/10
>
> have any idea?
>
> thanks
> jon
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
