From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 4/4] ipv6: coding style - cleanse bracing
Date: Wed, 3 Sep 2014 07:52:52 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B310A4@avmb3.qlogic.org>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk>
 <1409685364-4327-5-git-send-email-ipm@chirality.org.uk>
 <54066F6D.4060406@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kvGyRCNUhGIzFRTEAbKEI=?=
	<hideaki.yoshifuji@miraclelinux.com>,
	Ian Morris <ipm@chirality.org.uk>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:10369 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751114AbaICHx2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 03:53:28 -0400
In-Reply-To: <54066F6D.4060406@miraclelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,
>
> Ian Morris wrote:
> > Tidy up braces in a few places (mainly if statements):
> > * remove unnecessary braces
> > * add braces for single line statements where part of an "else" where
> > the other branch has braces
>
> Hmm, I am not for this change.
>
> If "if" (or "else") statement occupies multiple lines, I want to see braces even if it
> contains a single statement.
> On the other hand, especiallly if the statement occupiles only one line (and the
> logic do not require those braces), no braces.
>
> e.g. 1
>     if (cond)
>             statement();
>     else {
>             statement2(argument,
>                        argument2);
>     }

I was under the impression the coding style require matching curly braces on all
if and else clauses, e.g., in the previous example I would have expected the `if' to
have curly braces since its else block has them, regardless of whether its
statement-block has more than a single line.

> e.g. 2
>     if (cond) {
>             if (cond2)
>                     statement();
>     } else
>             statement2(argument, argument2);
>
> e.g. 3
>     if (cond) {
>             /* comment */
>             statement();
>     }

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
