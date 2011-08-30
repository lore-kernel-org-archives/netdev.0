From: Jim Gettys <jg@freedesktop.org>
Subject: Re: BQL crap and wireless
Date: Mon, 29 Aug 2011 22:12:17 -0400
Message-ID: <4E5C4701.4060509@freedesktop.org>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <903AA8A8-9ACD-44FB-9BA8-50137359EC2B@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Andrew McGregor <andrewmcgr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55388 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161Ab1H3CMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 22:12:21 -0400
In-Reply-To: <903AA8A8-9ACD-44FB-9BA8-50137359EC2B@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2011 09:59 PM, Andrew McGregor wrote:
> On 30/08/2011, at 1:22 PM, Jim Gettys wrote:
>
>> The gotcha is we don't have a AQM algorithm known to work in
>> the face of the highly dynamic bandwidth variation that is wireless
> It's worse than highly dynamic... the bandwidth may be completely undefined moment to moment, as it is dependent on both the wireless environment, which varies on timescales that can be about equal to a packet transmit time, and on the traffic mix.  There's about 30 ms of correlation time at best.
Yup.  It makes ethernet look trivial. If we can handle buffers there,
everywhere else is easy by comparison.
>>  This was/is
>> the great surprise to me as I had always thought of AQM as a property of
>> internet routers, not hosts.
> There's no distinction in the forwarding plane, every router is a host, every host is a router.
Exactly; but I hadn't thought this through to hosts, nor, I think had
many other people.  Naive me, having been scarred by '90's congestion,
was aware of RED, and roughly how it worked, but always thought of AQM
as something you did in routers.  Realising that in principle I needed
it turned on in my laptop was not something I expected.
                        - Jim
