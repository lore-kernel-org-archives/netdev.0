From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [RFC 2/3] =?UTF-8?Q?if=5Fether=2Eh=3A=20Add=20IEEE=20=38=30=32=2E=31?=
 =?UTF-8?Q?=20Local=20Experimental=20Ethertype=20=31=2E?=
Date: Mon, 05 Dec 2011 15:03:17 +0100
Message-ID: <ff290c739be323dec89d19ed905feb94@chewa.net>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com> <1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com> <5636a5efd90c56b538569ab019d7be4c@chewa.net> <CAJK669bK8kBXfc=j1q5NWEDCgSZwO0O=LsZ8z5GzB0S07gwBEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:50642 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151Ab1LEODT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 09:03:19 -0500
In-Reply-To: <CAJK669bK8kBXfc=j1q5NWEDCgSZwO0O=LsZ8z5GzB0S07gwBEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Dec 2011 14:14:30 +0100, Sjur Br=C3=A6ndeland <sjurbren@gmail=
=2Ecom>=0D
wrote:=0D
>> I don't think you can just go and steal a reserved EtherType. What i=
f=0D
>> some user-space (using packet sockets) or out-of-tree kernel driver=0D
>> does actual "experiment" with this type?=0D
> =0D
> I don't think defining this type in if_ether.h would harm anyone ;-)=0D
> =0D
> I think your comments are applicable for the patch:=0D
> "caif: Add support for CAIF over CDC NCM USB interface".=0D
=0D
That patch makes no sense without this patch. I comment on the first pa=
tch=0D
in the series that exhibits the problem.=0D
=0D
> Currently CAIF over CDC NCM USB is only deployed for the Ethernet lin=
k=0D
> between Host and Modem internally in a Smart Phone, and not out of th=
e=0D
> Smart Phone (Tethering). The modem's Ethernet interface is connected =
to=0D
> the CAIF stack and not to the modem's IP stack.On the Linux Host,=0D
> CAIF takes this EthType into use *only* for a Ethernet interface with=
=0D
> the VID/PID of a ST-E CAIF modem.=0D
=0D
It's even weirder then. If you have control over both ends and the NCM =
1.0=0D
interface is not adequate, then you really should use your own CDC clas=
s=0D
for the purpose.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net/=0D
