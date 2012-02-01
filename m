From: yao zhao <yao.development@gmail.com>
Subject: Re: Introducing open source MSTP daemon
Date: Wed, 1 Feb 2012 11:30:12 -0500
Message-ID: <CADDf=MRCS61iDM+W=6dy+1mQiTE7HJK+7dSJQVUfx2wE9Qtgmw@mail.gmail.com>
References: <201109221727.33010.vitas@nppfactor.kiev.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org,
	"Srinivas M.A." <srinivas.aji@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alex Rozin <alexr@nbase.co.il>,
	Michael Rozhavsky <mike@nbase.co.il>
To: Vitalii Demianets <vitas@nppfactor.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:47216 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752499Ab2BAQaN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 11:30:13 -0500
Received: by obcva7 with SMTP id va7so1492005obc.19
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2012 08:30:12 -0800 (PST)
In-Reply-To: <201109221727.33010.vitas@nppfactor.kiev.ua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nice job!

Will try! more work needed in kernel!

yao

On Thu, Sep 22, 2011 at 10:27 AM, Vitalii Demianets
<vitas@nppfactor.kiev.ua> wrote:
> Good day!
> I am happy to introduce open source MSTP daemon:
> http://sourceforge.net/p/mstpd
>
> Of course due to current limitations of the Linux bridge code, namely=
:
> =A0- no integration with VLAN code
> =A0- no support of different FIDs (independent learning)
> =A0- no support of the per-MSTI port states
> this daemon is not very useful for the bare Linux box. It can work on=
ly with
> support of specialized driver which talks to the MSTP-aware hardware =
(most of
> the today ethernet switching parts are MSTP-aware and support FIDs an=
d
> per-MSTI port states).
> Nevertheless I hope to find some interest in my work. Maybe it will s=
timulate
> in some way the integration of the Linux bridge and VLAN code, who kn=
ows?
> From the IEEE point of view they are already merged, see 802.1Q-2005 =
which
> incorporates previous editions of 802.1q and 802.1d and 802.1w/s.
>
> Once again, all interested are welcome. Please review, criticize, tes=
t,
> modify, patch, deploy and do other things :) Any kind of feedback is
> extremely welcome :)
>
> --
> Vitalii Demianets
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
