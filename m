From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RESEND PATCH net-next] xfrm: add LINUX_MIB_XFRMACQUIREERROR
 statistic counter
Date: Tue, 4 Jun 2013 13:29:07 +0200
Message-ID: <20130604112907.GB3109@secunet.com>
References: <1369014025-19564-1-git-send-email-fan.du@windriver.com>
 <519A2F1A.3010703@cogentembedded.com>
 <519ACC50.5030402@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	herbert@gondor.hengli.com.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49485 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114Ab3FDL3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 07:29:13 -0400
Content-Disposition: inline
In-Reply-To: <519ACC50.5030402@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 09:22:24AM +0800, Fan Du wrote:
> Hi, Sergei
>=20
> On 2013=E5=B9=B405=E6=9C=8820=E6=97=A5 22:11, Sergei Shtylyov wrote:
> >Hello.
> >
> >On 20-05-2013 5:40, Fan Du wrote:
> >
> >>When host ping its peer, ICMP echo request packet triggers IPsec
> >>policy, then host negotiates SA secret with its peer. After IKE
> >>installed SA for OUT direction, but before SA for IN direction
> >>installed, host get ICMP echo reply from its peer. At the time
> >>being, the SA state for IN direction could be XFRM_STATE_ACQ,
> >>then the received packet will be dropped after adding
> >>LINUX_MIB_XFRMINSTATEINVALID statistic.
> >
> >>Adding a LINUX_MIB_XFRMACQUIREERROR statistic counter for such
> >>scenario when SA in larval state is much clearer for user than
> >>LINUX_MIB_XFRMINSTATEINVALID which indicates the SA is totally
> >>bad.
> >
> >>Signed-off-by: Fan Du <fan.du@windriver.com>
> >>---
> >>include/uapi/linux/snmp.h | 1 +
> >>net/xfrm/xfrm_input.c | 5 +++++
> >>net/xfrm/xfrm_proc.c | 1 +
> >>3 files changed, 7 insertions(+), 0 deletions(-)
> >
> >>diff --git a/include/uapi/linux/snmp.h b/include/uapi/linux/snmp.h
> >>index df2e8b4..3d072bf 100644
> >>--- a/include/uapi/linux/snmp.h
> >>+++ b/include/uapi/linux/snmp.h
> >>@@ -287,6 +287,7 @@ enum
> >>LINUX_MIB_XFRMOUTPOLERROR, /* XfrmOutPolError */
> >>LINUX_MIB_XFRMFWDHDRERROR, /* XfrmFwdHdrError*/
> >>LINUX_MIB_XFRMOUTSTATEINVALID, /* XfrmOutStateInvalid */
> >>+ LINUX_MIB_XFRMACQUIREERROR, /* XfrmAcquireError*/
> >
> >Please indent the comment with tabs and align with the above ones.
>=20
> Thanks for the point, I will fix this in next round after reviewing f=
rom Steffen and others.
>=20

The patch looks ok to me, please fix the indent and resend.

Thanks!
