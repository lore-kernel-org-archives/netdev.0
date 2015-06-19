From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] bridge: multicast: start querier timer when running user-space stp
Date: Fri, 19 Jun 2015 16:51:37 +0300
Message-ID: <BC514222-4EA9-4F73-9BEE-D2345B884475@cumulusnetworks.com>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com> <20150619134734.GA14548@gondor.apana.org.au>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, sashok@cumulusnetworks.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36109 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbFSNvl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 09:51:41 -0400
Received: by wicnd19 with SMTP id nd19so19759235wic.1
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 06:51:40 -0700 (PDT)
In-Reply-To: <20150619134734.GA14548@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 19, 2015, at 4:47 PM, Herbert Xu <herbert@gondor.apana.org.au>=
 wrote:
>=20
> On Fri, Jun 19, 2015 at 01:45:50AM -0700, Nikolay Aleksandrov wrote:
>> When STP is running in user-space and querier is configured, the
>> querier timer is not started when a port goes to a non-blocking stat=
e.
>> This patch unifies the user- and kernel-space stp multicast port ena=
ble
>> path and enables it in all states different from blocking. Note that=
 when a
>> port goes in BR_STATE_DISABLED it's not enabled because that is hand=
led
>> in the beginning of the port list loop.
>>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
>=20
> On a related note, we never disable the multicast querying when
> the port goes into blocking mode and we probably should.  So could
> you take a look at that and create a patch for it?
>=20
> Thanks,
> --=20
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in

Good catch, I=E2=80=99ll look into it.

Thanks,
 Nik--
To unsubscribe from this list: send the line "unsubscribe netdev" in
