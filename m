From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: multicast: disable port when in blocking state
Date: Tue, 23 Jun 2015 13:26:12 +0300
Message-ID: <77FF1B4A-1D3A-4F59-A7C7-0ADBB34F8920@cumulusnetworks.com>
References: <1434703550-29305-1-git-send-email-nikolay@cumulusnetworks.com> <1435003931-6418-1-git-send-email-nikolay@cumulusnetworks.com> <EA66CF77-F024-471C-A8F1-A7E6C3DB1721@cumulusnetworks.com> <709324EA-9BEC-43AD-9DC1-55F712C378E6@cumulusnetworks.com> <20150622235215.GA14897@gondor.apana.org.au>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sashok@cumulusnetworks.com,
	davem@davemloft.net, stephen@networkplumber.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:34901 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbbFWK0Q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 06:26:16 -0400
Received: by wgbhy7 with SMTP id hy7so5457975wgb.2
        for <netdev@vger.kernel.org>; Tue, 23 Jun 2015 03:26:15 -0700 (PDT)
In-Reply-To: <20150622235215.GA14897@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 23, 2015, at 2:52 AM, Herbert Xu <herbert@gondor.apana.org.au>=
 wrote:
>=20
> On Mon, Jun 22, 2015 at 11:38:36PM +0300, Nikolay Aleksandrov wrote:
>>=20
>> One more thing - I don=E2=80=99t think we need any additional change=
s because there=E2=80=99s a check in
>> br_multicast_port_query_expired():
>>      if (port->state =3D=3D BR_STATE_DISABLED ||
>>            port->state =3D=3D BR_STATE_BLOCKING)
>>                goto out;
>>=20
>> So it looks like the port should be fine (i.e. not sending) when it =
goes in blocking state.
>=20
> Thanks for looking into this! Perhaps we could at least add a
> comment to state that the disable_port isn't needed because the
> timers will expire and kill themselves automatically?  I think
> adding it to the place where you were going to place the disable_port
> call would be the most obvious.
>=20
> Thanks,
> --=20
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

Right, sounds good. I=E2=80=99ll post a patch with the comment in a bit=
=2E

Thank you,
 Nik