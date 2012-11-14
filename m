From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [v6 PATCH 1/8] cxgb4/cxgb4vf: Chelsio FCoE offload driver
 submission (common header updates).
Date: Tue, 13 Nov 2012 18:26:48 -0800
Message-ID: <1352860008.28921.2.camel@dabdike>
References: <1351158621-32222-1-git-send-email-naresh@chelsio.com>
	 <1351158621-32222-2-git-send-email-naresh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-scsi@vger.kernel.org, dm@chelsio.com, leedom@chelsio.com,
	netdev@vger.kernel.org, chethan@chelsio.com
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:55984 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755145Ab2KNHDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 02:03:01 -0500
In-Reply-To: <1351158621-32222-2-git-send-email-naresh@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 15:20 +0530, Naresh Kumar Inna wrote:
> This patch contains updates to firmware/hardware header files shared
> between csiostor and cxgb4/cxgb4vf, and the resulting changes to the
> cxgb4/cxgb4vf source files.
>=20
> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> ---
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++--
>  drivers/net/ethernet/chelsio/cxgb4/sge.c        |    6 ++--
>  drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   20 +++++-----
>  drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |    1 +
>  drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   36 +++++++++++++=
++++++-
>  drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   41 +++++++++++++=
+++++++---
>  drivers/net/ethernet/chelsio/cxgb4vf/sge.c      |    8 ++--
>  7 files changed, 92 insertions(+), 28 deletions(-)

This still doesn't compile:

drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c: In function =E2=80=98a=
dap_init0=E2=80=99:
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:3932:10: error: =E2=80=98=
struct fw_caps_config_cmd=E2=80=99 has no member named =E2=80=98retval_=
len16=E2=80=99
make[5]: *** [drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.o] Error 1

James
