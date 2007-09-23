From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: incorrect cksum with tcp/udp on lo with 2.6.20/2.6.21/2.6.22
Date: Sun, 23 Sep 2007 23:18:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709232317001.24758@bizon.gios.gov.pl>
References: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-868810198-1190582338=:24758"
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:37790 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255AbXIWVTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2007 17:19:16 -0400
In-Reply-To: <E1IZJFo-0006ta-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-868810198-1190582338=:24758
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sun, 23 Sep 2007, Herbert Xu wrote:

> Krzysztof Oledzki <olel@ans.pl> wrote:
>>
>> It seems that after some not very recent changes udp and tcp packes
>> carring data send by a loopback have incorrect cksum:
>
> This correct.  The loopback interfaces has the no checksum flag
> set so we only provide a partial checksum on output (i.e., the
> pseudoheader without the payload).
>
> We even export this to user-space via a flag.  So you should fix
> tcpdump to read this flag and ignore the checksum.

Thank you for the information. Is there any easy way to turn them on? I=20
need it for LVS.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-868810198-1190582338=:24758--
