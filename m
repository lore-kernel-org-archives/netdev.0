From: Arvid Brodin <arvid.brodin@alten.se>
Subject: Re: [PATCH IPROUTE] ip: Add HSR support
Date: Mon, 25 Nov 2013 20:20:47 +0100
Message-ID: <5293A30F.6030407@alten.se>
References: <527D3CCC.3020609@xdin.com> <20131122173334.0ae81887@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:55047 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753723Ab3KYTUu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 14:20:50 -0500
In-Reply-To: <20131122173334.0ae81887@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-11-23 02:33, Stephen Hemminger wrote:
> On Fri, 8 Nov 2013 20:34:36 +0100
> Arvid Brodin <arvid.brodin@xdin.com> wrote:
>
>> This patch adds basic support for High-Availability Seamless
>> Redundancy (HSR) network devices.
>>
>> Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>
>
> Will not apply to current iproute source. The header files have been =
updated
> to be from current upstream (linus), and the IFLA_HSR doesn't match.

So, what's the least annoying (for everyone) way of getting the updated=
 header
file into the kernel _and_ iproute?

I guess the iproute patch should be against net-next-for-3.13? (The HSR=
 kernel
patch was picked up into 3.13-rc1.)

And the updated kernel patch (with the .fill_info routine implemented a=
nd the
updated header file), where do I send that?


--
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/

________________________________
Xdin is changing its name. From 25 November 2013 we will be known as Al=
ten. Read more at www.alten.se
