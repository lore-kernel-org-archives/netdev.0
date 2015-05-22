From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] xen-netfront crash when detaching network while some
 network activity
Date: Fri, 22 May 2015 17:25:44 +0100
Message-ID: <555F5888.4020303@citrix.com>
References: <20150522114932.GC8664@mail-itl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, xen-devel <xen-devel@lists.xen.org>
To: =?windows-1252?Q?Marek_Marczykowski-G=F3recki?=
	<marmarek@invisiblethingslab.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:54149 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161018AbbEVQZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 12:25:47 -0400
In-Reply-To: <20150522114932.GC8664@mail-itl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/05/15 12:49, Marek Marczykowski-G=F3recki wrote:
> Hi all,
>=20
> I'm experiencing xen-netfront crash when doing xl network-detach whil=
e
> some network activity is going on at the same time. It happens only w=
hen
> domU has more than one vcpu. Not sure if this matters, but the backen=
d
> is in another domU (not dom0). I'm using Xen 4.2.2. It happens on ker=
nel
> 3.9.4 and 4.1-rc1 as well.
>=20
> Steps to reproduce:
> 1. Start the domU with some network interface
> 2. Call there 'ping -f some-IP'
> 3. Call 'xl network-detach NAME 0'

I tried this about 10 times without a crash.  How reproducible is it?

I used a 4.1-rc4 frontend and a 4.0 backend.

David
