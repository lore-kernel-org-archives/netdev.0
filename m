From: =?ISO-8859-15?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 16:57:35 +0200
Message-ID: <488746DF.1050501@tvcablenet.be>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be> <48870425.50908@trash.net> <48871632.3010205@tvcablenet.be> <4887169B.6090102@trash.net> <488725D5.8030900@tvcablenet.be> <488727B3.7040007@trash.net> <48872968.9000103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agave.telenet-ops.be ([195.130.137.77]:33075 "EHLO
	agave.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbYGWO5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 10:57:40 -0400
In-Reply-To: <48872968.9000103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Patrick McHardy wrote:
>> Fran=E7ois Valenduc wrote:
>>> Patrick McHardy a =E9crit :
>>>> Interesting. Could you post straces of both commands please?
>>>>
>>> I also send the output of strace for dhcpd under kernel 2.6.26=20
>>> (where it works correctly).
>>
>> Thanks, I couldn't spot anything in these traces. I'll try to
>> reproduce this with iwl3945.
>
>
> Well, no luck, the current -git kernel doesn't boot on my notebook
> and I don't have time for a bisection currently. Could someone
> else try to verify/debug this?
>
>
I did the bisection again, this time on the whole tree and the first ba=
d=20
commit is again the one I mentioned previously:

175f9c1bba9b825d22b142d183c9e175488b260c is first bad commit
commit 175f9c1bba9b825d22b142d183c9e175488b260c
Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date:   Sun Jul 20 00:08:47 2008 -0700

    net_sched: Add size table for qdiscs

    Add size table functions for qdiscs and calculate packet size in
    qdisc_enqueue().

    Based on patch by Patrick McHardy
     http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2

This time, I didn't encounter kernels which didn't compile. So, I didn'=
t=20
use git-reset or git-bisect skip.

=46ran=E7ois

