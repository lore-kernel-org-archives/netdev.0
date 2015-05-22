From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net,stable-4.0] cdc_ncm: Fix tx_bytes statistics
Date: Fri, 22 May 2015 20:48:01 +0200
Message-ID: <758FD608-F046-4FC8-BB2A-5D91F01F3F78@mork.no>
References: <1432293322-11928-1-git-send-email-bjorn@mork.no> <1432315367.22824.19.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Florian Bruhin <me@the-compiler.org>,
	linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52842 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757114AbbEVSrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 14:47:37 -0400
In-Reply-To: <1432315367.22824.19.camel@codethink.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 22 May 2015 19:22:47 CEST, Ben Hutchings <ben.hutchings@codethink.co=
=2Euk> wrote:
>On Fri, 2015-05-22 at 13:15 +0200, Bj=C3=B8rn Mork wrote:
>> The tx_curr_frame_payload field is u32. When we try to calculate a
>> small negative delta based on it, we end up with a positive integer
>> close to 2^32 instead.  So the tx_bytes pointer increases by about
>> 2^32 for every transmitted frame.
>>=20
>> Fix by calculating the delta as a signed long.
>
>Told you I hadn't tested it.


Yes, I know. This was all my bad. Sorry. Didn't mean to imply that you =
were to blame here. On the contrary. Thanks again for showing how to so=
lve this.


Bj=C3=B8rn
