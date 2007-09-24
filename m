From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Mon, 24 Sep 2007 11:44:19 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709241128490.26474@bizon.gios.gov.pl>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au>
 <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl>
 <20070924013005.GB22054@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1510962583-1190627059=:26474"
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:49910 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbXIXJoj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 05:44:39 -0400
In-Reply-To: <20070924013005.GB22054@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1510962583-1190627059=:26474
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 24 Sep 2007, Herbert Xu wrote:

> On Sun, Sep 23, 2007 at 11:18:58PM +0200, Krzysztof Oledzki wrote:
>>
>> Thank you for the information. Is there any easy way to turn them on? I
>> need it for LVS.
>
> Do you really need it?

Yes. I would like to use a LVS redirector as both a client and a director:
  http://www.austintek.com/LVS/LVS-HOWTO/HOWTO/LVS-HOWTO.LVS-DR.html#direct=
or_as_client_in_LVS-DR

> The packets should be checksummed at the point where they physically
> leave the host.

So, with DR mode, packet goes by the lo device (with bad checksum) and=20
then get redirected outside. Unfortunately, when it leaves host it has bad=
=20
checksum, too. :(

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1510962583-1190627059=:26474--
