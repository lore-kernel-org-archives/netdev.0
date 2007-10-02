From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Tue, 2 Oct 2007 16:15:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710021606550.3175@bizon.gios.gov.pl>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au>
 <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl>
 <20070924013005.GB22054@gondor.apana.org.au> <Pine.LNX.4.64.0709241128490.26474@bizon.gios.gov.pl>
 <20071002104033.GA30281@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-95351712-1191334214=:3175"
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:47823 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbXJBOPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 10:15:42 -0400
In-Reply-To: <20071002104033.GA30281@gondor.apana.org.au>
Content-ID: <Pine.LNX.4.64.0710021612390.3647@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-95351712-1191334214=:3175
Content-Type: TEXT/PLAIN; CHARSET=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <Pine.LNX.4.64.0710021612391.3647@bizon.gios.gov.pl>



On Tue, 2 Oct 2007, Herbert Xu wrote:

> On Mon, Sep 24, 2007 at 11:44:19AM +0200, Krzysztof Oledzki wrote:
>>
>> So, with DR mode, packet goes by the lo device (with bad checksum) and
>> then get redirected outside. Unfortunately, when it leaves host it has b=
ad
>> checksum, too. :(
>
> Did you check this by taking a tcpdump on an external host?
Yes.

> Doing a local tcpdump doesn't work as tcpdump won't show the
> correct checksum if checksum offload is enabled.
Indeed, I'm aware about this.

> If it's really sending a bogus checksum then it's a bug in
> LVS.

I'm not sure if we should call it a bug. LVS does not support such=20
configuration by default - it requires kernel patching. However, it worked=
=20
with older kernels so that's why I asked if it is possible to force full=20
TCP/UDP checksum calculation?

Thank you.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-95351712-1191334214=:3175--
