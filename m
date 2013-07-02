From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC] cdc_ncm.c: make rx and tx functions exportable
Date: Tue, 02 Jul 2013 14:01:38 +0200
Message-ID: <87wqp9xja5.fsf@nemi.mork.no>
References: <alpine.LNX.2.02.1307021241380.8884@eeeadesso>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35271 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750769Ab3GBMBn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 08:01:43 -0400
In-Reply-To: <alpine.LNX.2.02.1307021241380.8884@eeeadesso> (Enrico Mioso's
	message of "Tue, 2 Jul 2013 12:43:40 +0200 (CEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> This patch factors out rx and tx fixup functions from cdc_ncm.c drive=
r.
> This will be useful once implementing a specific driverto handle
> huawei specific ncm implementation.

It is good to keep this change as a separate patch, but it needs to be
sumbitted as part of a series including the code using it.  Most
reviewers are unable to understand plain text - they can only read code
:)

So it is better to keep this for yourself until you have a working
driver using the exported functions, and then post it all as a patch
series.  That's the best way to show how you intend to use stuff like
this.

And I suggest you CC Alexey Orishko for all changes to the cdc_ncm
driver.  The ST-Ericsson address in the driver is probably bouncing now=
,
but you can reach him at "Alexey Orishko <alexey.orishko@gmail.com>"



Bj=C3=B8rn
