From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] TCP: avoid to send keepalive probes if receiving
 data
Date: Tue, 27 Apr 2010 12:55:12 -0700 (PDT)
Message-ID: <20100427.125512.220060084.davem@davemloft.net>
References: <20100426.112422.246526700.davem@davemloft.net>
	<1272342807-13379-1-git-send-email-fleitner@redhat.com>
	<alpine.DEB.2.00.1004270906320.13989@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fleitner@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756756Ab0D0TzH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 15:55:07 -0400
In-Reply-To: <alpine.DEB.2.00.1004270906320.13989@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 27 Apr 2010 09:08:08 +0300 (EEST)

> On Tue, 27 Apr 2010, Flavio Leitner wrote:
>=20
>> RFC 1122 says the following:
>> ...
>>   Keep-alive packets MUST only be sent when no data or
>>   acknowledgement packets have been received for the
>>   connection within an interval.
>> ...
>>=20
>> The acknowledgement packet is reseting the keepalive
>> timer but the data packet isn't. This patch fixes it by
>> checking the timestamp of the last received data packet
>> too when the keepalive timer expires.
>>=20
>> Signed-off-by: Flavio Leitner <fleitner@redhat.com>
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks everyone.
