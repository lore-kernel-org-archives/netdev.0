From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net] net: qmi_wwan: fix Gobi device probing
Date: Sat, 23 Jun 2012 12:05:46 +0200
Message-ID: <87txy2ibr8.fsf@nemi.mork.no>
References: <1340282758-18085-1-git-send-email-bjorn@mork.no>
	<20120622.171735.637204872051168180.davem@davemloft.net>
	<87y5neidk1.fsf@nemi.mork.no>
	<20120623.023749.1066357959466872561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	H.Siebmanns@t-online.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34643 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032Ab2FWKFx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jun 2012 06:05:53 -0400
In-Reply-To: <20120623.023749.1066357959466872561.davem@davemloft.net> (David
	Miller's message of "Sat, 23 Jun 2012 02:37:49 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Bj=C3=B8rn Mork <bjorn@mork.no>
> Date: Sat, 23 Jun 2012 11:26:54 +0200
>
>> Is waiting for 3.6-rc1 the best alternative, or is cherry-picking th=
em
>> an option?
>
> I'm extremely reluctant to have a dependency on another tree.

fair enough

> The USB tree, on the other hand, could pull the net-next tree
> in so you can continue your dependent work there.

OK, that will be up to Greg then.

But failing that, would it be OK to let the 3.6 version of the fix wait
for -rc2?  It's not a crash or any other kind of data loss bug, just a
usability regression with a workaround.


Bj=C3=B8rn
