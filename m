From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p
 packet)
Date: Mon, 14 Jun 2010 19:11:31 +0200
Message-ID: <4C1662C3.3070708@trash.net>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com>	 <1276466190.14011.223.camel@localhost>	 <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com> <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pedro Garcia <pedro.netdev@dondevamos.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54470 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756358Ab0FNRLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 13:11:33 -0400
In-Reply-To: <1276534945.2074.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
>   
>> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
>> <bhutchings@solarflare.com> wrote:
>>     
>>> I have no particular opinion on this change, but you need to read and
>>> follow Documentation/SubmittingPatches.
>>>
>>> Ben.
>>>       
>> Sorry, first kernel patch, and I did not know about it. I resubmit with
>> the correct style / format:
>>     
> [...]
>
> Sorry, no you haven't.
>
> - Networking changes go through David Miller's net-next-2.6 tree so you
> need to use that as the baseline, not 2.6.26
> - Patches should be applicable with -p1, not -p0 (so if you use diff,
> you should run it from one directory level up)
> - The patch was word-wrapped

Additionally:

- please use the proper comment style, meaning each line begins
  with a '*'

- the pr_debug statements may be useful for debugging, but are
  a bit excessive for the final version

- + /* 2010-06-13: Pedro Garcia

   We have changelogs for this, simply explaining what the code
   does is enough.

- Please CC the maintainer (which is me)
