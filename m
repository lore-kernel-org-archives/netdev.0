From: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Subject: Re: [PATCH 1/2] 8139too: clean up spaces and TABs
Date: Sun, 15 Jun 2008 09:50:23 +0200
Message-ID: <4854C9BF.8040900@freemail.hu>
References: <4853BB62.1060109@freemail.hu> <4853C8AD.9020407@s5r6.in-berlin.de> <48541165.7050304@freemail.hu> <485421C1.8010102@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01d.mail.t-online.hu ([84.2.42.6]:53334 "EHLO
	mail01d.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940AbYFOHu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 03:50:28 -0400
In-Reply-To: <485421C1.8010102@s5r6.in-berlin.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter wrote:
> N=E9meth M=E1rton wrote:
>> From: M=E1rton N=E9meth <nm127@freemail.hu>
>>
>> Clean up the following errors and warnings reported by checkpatch.pl=
:
>=20
> Is 8139too in active development or are there people actively fixing=20
> current bugs in it?  If not, a whitespace cleanup may be considered a=
=20
> waste of time.  There are even a few valid arguments that such change=
s=20
> are harmful then.
>=20
>>  - space prohibited between function name and open parenthesis '('
>>  - space required before the open brace '{'
>>  - code indent should use tabs where possible
>>  - line over 80 characters
>>  - spaces required around that '=3D' (ctx:VxW)
>=20
> Did you check that your whitespace changes are indeed only whitespace=
=20
> changes, i.e. that resulting assembler is unchanged?  If you checked =
it,=20
> it's worth mentioning in the submission.

Yes, I checked this. When I compared the "objdump -d" output I found th=
at
only the function calls are changed where the __LINE__ is a parameter.

Sorry about taking your time. My intention was to make the 8139too sour=
ce
code better as I am using this driver actively to communicate with the
digital world. I have chosen the checkpatch.pl's output to compare the
whether the old and the new code are better or not. Maybe that was a mi=
stake.

I would like to try it again, but in a different way. I collected here
the different problems reported by checkpatch.pl. I divided it to two
groups according to your comments which I think it worth to deal with:

 + ERROR: Macros with complex values should be enclosed in parenthesis
 + WARNING: __func__ should be used instead of gcc specific __FUNCTION_=
_
 + WARNING: plain inline is preferred over __inline__
 + WARNING: Use #include <linux/io.h> instead of <asm/io.h>
 + WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>

and the second group which it seems that may hurt somebody:

 - ERROR: code indent should use tabs where possible
 - ERROR: space required after that ',' (ctx:VxV)
 - ERROR: space required before the open brace '{'
 - ERROR: space required before the open parenthesis '('
 - ERROR: spaces required around that '=3D' (ctx:VxW)
 - ERROR: trailing statements should be on next line
 - WARNING: braces {} are not necessary for single statement blocks
 - WARNING: do not add new typedefs
 - WARNING: line over 80 characters
 - WARNING: space prohibited between function name and open parenthesis=
 '('

This is a much smaller set of changes. What do you think?

Regards,

	M=E1rton N=E9meth

