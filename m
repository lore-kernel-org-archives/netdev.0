From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 3/3] x25: Move to staging
Date: Tue, 23 Nov 2010 16:05:13 +1100
Message-ID: <AANLkTi=LA7o0o16DRQF6af1+mgPapV5sUm-hQNC1ou3V@mail.gmail.com>
References: <1290484528.6770.1336.camel@localhost>
	<20101122203155.27534f3b@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	netdev <netdev@vger.kernel.org>, devel@driverdev.osuosl.org,
	Debian kernel maintainers <debian-kernel@lists.debian.org>,
	linux-x25@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39833 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab0KWFFP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 00:05:15 -0500
In-Reply-To: <20101122203155.27534f3b@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are users of linux X.25 for production environments, please don't=
=2E.
It works well enough, there have been some X.25 over TCP bits of code
floating around the Internet and mailing lists.
There is an x25 loopback device on sourceforge using tuntap which I
have been using to test slowly removing the bkls.

Regards,
Andrew.

On Tue, Nov 23, 2010 at 3:31 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 23 Nov 2010 03:55:28 +0000
> Ben Hutchings <ben@decadent.org.uk> wrote:
>
>> Recent review has revealed several bugs in obscure protocol
>> implementations that can be exploited by local users for denial of
>> service or privilege escalation.
>>
>> The x25 protocol (PF_X25) receives only 'odd fixes'. =A0There appear=
 to
>> be no published applications for it, and it has never progressed
>> beyond 'experimental' status.
>>
>> This protocol generally should not be enabled by distributions, sinc=
e
>> the cost of a security flaw affecting all installed systems presumab=
ly
>> outweighs the benefit to the few (if any) legitimate users.
>>
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> ---
>> I'm somewhat less sure about this one; maybe it's improving? =A0But =
there
>> is little enough sign of any usefulness after 10 years.
>>
>> There are several X25 dependencies that presumably should be moved t=
oo.
>
> No. If you don't like it then don't enable it.
>
