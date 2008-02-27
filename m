From: "Wappler Marcel" <Marcel.Wappler@bridgeco.net>
Subject: RE: [PATCH] [resend]The kernel gets no IP from some DHCP servers, 2.6.24
Date: Wed, 27 Feb 2008 18:25:10 +0100
Message-ID: <83116F0A4FF67A4F97BA0B6E408C48E301C5CE6D@zuerich.BC-Int.NET>
References: <83116F0A4FF67A4F97BA0B6E408C48E301C5CDEF@zuerich.BC-Int.NET><47C55BBF.7080501@trash.net><83116F0A4FF67A4F97BA0B6E408C48E301C5CE08@zuerich.BC-Int.NET> <20080227083819.70ddb374@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Patrick McHardy" <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, <ebiederman@lnxi.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755339AbYB0RZb@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20080227083819.70ddb374@extreme>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
>> In my opinion it is necessary to distinguish between INADDR_ANY and=20
>> the ZERO address which ist requested to be in the DHCPDISCOVER packe=
t.
>Just delete the lines and the address will be zero because of earlier =
memset().

=46rom my personal point of view it is important to document the requir=
ement of the
two addresses to be 0.0.0.0 either through the code itself or through a=
 comment
which states clear the side effect of memset'ting the structure.=20

Both roads lead to Rome :-)

Marcel
--
Marcel Wappler
Bridgeco AG
CH-8600 D=FCbendorf
Switzerland
