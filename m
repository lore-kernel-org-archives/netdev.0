From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net,stable 0/3] qmi_wwan: working around 3 serious
 firmware bugs
Date: Fri, 19 Apr 2013 18:15:46 -0500
Message-ID: <1366413346.21942.1.camel@dcbw.foobar.com>
References: <1366325831-13727-1-git-send-email-bjorn@mork.no>
	 <20130419.175156.87420722153479024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bjorn@mork.no, netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964871Ab3DSXN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 19:13:58 -0400
In-Reply-To: <20130419.175156.87420722153479024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 17:51 -0400, David Miller wrote:
> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Fri, 19 Apr 2013 00:57:08 +0200
>=20
> > This series adds workarounds for 3 different firmware bugs, each
> > preventing the affected devices from working at all. I therefore
> > humbly request that these fixes go to stable-3.8 (if still
> > maintained) and 3.9 (either via net if still possible, or via
> > stable if not).
> >=20
> > All 3 workarounds are applied to all devices supported by the drive=
r.
> > Adding quirks for specific devices was considered as an alternative=
,
> > but was rejected because we have too little information about the
> > exact distribution of the buggy firmwares. All we know is that the
> > same bug shows up in devices from at least 3 different, and presuma=
bly
> > independent, vendors.
> >=20
> > The workarounds have instead been designed to automatically apply
> > when necessary, and to have as little impact as possible on unaffec=
ted
> > devices.  The series has been tested on a number of devices both wi=
th
> > and without these bugs.
> >=20
> > The series should apply cleanly to net/master, net-next/master and
> > stable/linux-3.8.y
>=20
> Series applied and queued up for -stable, thanks!

You're fast :)  But in any case:

Tested-by: Dan Williams <dcbw@redhat.com>

Tested on Gobi 1K (known not to exhibit the raw-ip bug), Novatel E362,
and Pantech UML290.

Dan
