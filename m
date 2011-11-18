From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: b43: BCM 4331: MacBook 8,1: No connection after suspend
Date: Fri, 18 Nov 2011 21:09:02 +0100
Message-ID: <4EC6BB5E.4010101__45409.436178352$1321646981$gmane$org@broadcom.com>
References: <20111118173242.GA2101@schottelius.org>
 <20111118173921.GB2101@schottelius.org> <4EC6B9E9.50204@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Nico Schottelius" <nico-nospam@schottelius.org>,
	"Nico -telmich- Schottelius" <nico-linux-20111118@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <ne
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2610 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752093Ab1KRUJQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 15:09:16 -0500
In-Reply-To: <4EC6B9E9.50204@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/2011 09:02 PM, Arend van Spriel wrote:
> On 11/18/2011 06:39 PM, Nico Schottelius wrote:
>> Nico -telmich- Schottelius [Fri, Nov 18, 2011 at 06:32:42PM +0100]:
>>> Hello,
>>>
>>> new notebook, new problems (*):
>>
>> + full dmesg attached.
>>
>=20
> It seems you are running b43 + bcma. Adding Rafa=C5=82 and friends.
>=20
> Gr. AvS

Hi Rafa=C5=82,

In brcmsmac we reprogram the PCI BAR windows upon resume. Not sure if
that is done or needed in bcma, but may be worth checking.

Gr. AvS
