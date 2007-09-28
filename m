From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Upgrading 2.6.21.7->2.6.22.9 kills my network (sky2): sky2 eth0:
 rx error, status 0x402300 length 60
Date: Fri, 28 Sep 2007 13:11:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709281304590.17152@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0709280950160.17152@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0709281144530.17152@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-410334259-1190977887=:17152"
Cc: Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56130 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbXI1LLw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 07:11:52 -0400
In-Reply-To: <Pine.LNX.4.64.0709281144530.17152@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-410334259-1190977887=:17152
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Fri, 28 Sep 2007, Krzysztof Oledzki wrote:

>
>
> On Fri, 28 Sep 2007, Krzysztof Oledzki wrote:
>
>> Hello,
>>=20
>> After upgrading my kernel from 2.6.21.7 to 2.6.22.9 my 88E8053 no longer=
=20
>> works:
>
> Small update: 2.6.22.9 with sky2.c/sky2.h from 2.4.22.4 works without any=
=20
> problems.

Final update.

Reverting this patch:=20
http://git.kernel.org/?p=3Dlinux/kernel/git/stable/linux-2.6.22.y.git;a=3Dc=
ommitdiff_plain;h=3D8c07a8e30ba8a2e0831da4b134202598435f8358
solved my problem.

I also found this one:

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dcomm=
itdiff_plain;h=3Dd6532232cd3de79c852685823a9c52f723816d0a

Could it go to a next -stable ASAP, please? It seems that=20
2.6.22.5-2.6.22.9 kernels have broken sky2 if used with vlans. :( Such=20
regression in a -stable kernel isn't nice. :(

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-410334259-1190977887=:17152--
