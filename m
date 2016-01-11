From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next 6/8] net: gre: Implement LCO for GRE over IPv4
Date: Mon, 11 Jan 2016 19:02:51 +0000
Message-ID: <5693FC5B.3060904@solarflare.com>
References: <56901197.8040808@solarflare.com>
 <56901235.1010800@solarflare.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCC1D7E@AcuExch.aculab.com>
 <5693AC59.4080702@solarflare.com>
 <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>,
	"tom@herbertland.com" <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:31454 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933295AbcAKTDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 14:03:19 -0500
In-Reply-To: <CAKgT0UdSRi-iwZpBWrezg=-fFcVTFSd=2FOOye_oZr2oNCNJAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/16 18:39, Alexander Duyck wrote:
> On Mon, Jan 11, 2016 at 5:21 AM, Edward Cree <ecree@solarflare.com> wrote:
>> csum_fold complements, so if the sum comes to (say) 0x1fffe, it will return ~0xffff which is 0.
>>
>> Next version of patch will mangle 0 for both branches.
> Actually you may want to go the other way on that.  If they weren't
> flipping the checksum value for GRE before why should we start doing
> that now?  I'm pretty sure the checksum mangling is a very UDP centric
> thing.  There is no need to introduce it to other protocols.
Good catch, you're quite right.

-ed
