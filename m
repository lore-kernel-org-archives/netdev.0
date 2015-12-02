From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] i40e: Fix i40e_print_features() VEB mode output
Date: Wed, 02 Dec 2015 15:48:00 -0500 (EST)
Message-ID: <20151202.154800.1567031979226825020.davem@davemloft.net>
References: <1449045535.3716.10.camel@perches.com>
	<1449050215.3224.29.camel@intel.com>
	<1449051149.3716.20.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	shannon.nelson@intel.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbbLBUsB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:48:01 -0500
In-Reply-To: <1449051149.3716.20.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Joe Perches <joe@perches.com>
Date: Wed, 02 Dec 2015 02:12:29 -0800

> On Wed, 2015-12-02 at 01:56 -0800, Jeff Kirsher wrote:
>> On Wed, 2015-12-02 at 00:38 -0800, Joe Perches wrote:
>> > Commit 7fd89545f337 ("i40e: remove BUG_ON from feature string
>> > building")
>> > added defective output when I40E_FLAG_VEB_MODE_ENABLED was set in
>> > function i40e_print_features.
>> >=20
>> > Fix it.
>> >=20
>> > Miscellanea:
>> >=20
>> > o Remove unnecessary string variable
>> > o Add space before not after fixed strings
>> > o Use kmalloc not kzalloc
>> > o Don't initialize i to 0, use result of first snprintf
>> >=20
>> > Noticed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>=20
>> Don't you mean Reported-by? =A0I am not aware of Noticed-by as being=
 a
>> recognized signature.
>=20
> At least for the get_maintainer script, "<anything>-by:" is a signatu=
re

Is patchwork using the same regexp?  If not, for the time being don't
user non-standard tags, and furthermore please ask the patchwork folks
to use something similar to getmaintainer.pl

Thanks.
