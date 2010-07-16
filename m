From: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 17:23:40 -0700
Message-ID: <AANLkTikLBZ7E7iUR8fibVoYPDi5JBgC53tH6FMy1f8yZ@mail.gmail.com>
References: <4C3E0684.5060409@wildgooses.com>
	<4C3E1B54.40604@hp.com>
	<20100714203919.GD6682@nuttenaction>
	<20100714.145547.102555471.davem@davemloft.net>
	<20100714221301.GI6682@nuttenaction>
	<20100714234917.924f420d.billfink@mindspring.com>
	<AANLkTinbtGuMTPNyJqJtx_bqfQDPqbA1XqjhLe_pj1mX@mail.gmail.com>
	<4C3F66BA.8010002@hp.com>
	<20100715134857.38d519c5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Bill Fink <billfink@mindspring.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>, lists@wildgooses.com,
	davidsen@tmr.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100715134857.38d519c5@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't even consider a modest IW increase to 10 is aggressive. The sca=
ling
of IW is only adequate IMO given the huge b/w growth in the past
decade. Remember there could be plenty of flows sending large cwnd
bursts at
twice the bottleneck link rate at any point of time in the network anyw=
ay so
the "fairness" question may already be ill-defined. In any case we're
trying to conduct some experiment in a private testbed to hopefully
get some insights
with real data.

Jerry

On Thu, Jul 15, 2010 at 1:48 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 15 Jul 2010 12:51:22 -0700
> Rick Jones <rick.jones2@hp.com> wrote:
>
>> I have to wonder if the only heuristic one could employ for divining=
 the initial
>> congestion window is to be either pessimistic/conservative or
>> optimistic/liberal. =A0Or for that matter the only one one really ne=
eds here?
>>
>> That's what it comes down to doesn't it? =A0At any one point in time=
, we don't
>> *really* know the state of the network and whether it can handle the=
 load we
>> might wish to put upon it. =A0We are always reacting to it. Up until=
 now, it has
>> been felt necessary to be pessimistic/conservative at time of connec=
tion
>> establishment and not rely as much on the robustness of the "control=
" part of
>> avoidance and control.
>>
>> Now, the folks at Google have lots of data to suggest we don't need =
to be so
>> pessimistic/conservative and so we have to decide if we are willing =
to be more
>> optimistic/liberal. =A0Broadly handwaving, the "netdev we" seems to =
be willing to
>> be more optimistic/liberal in at least a few cases, and the question=
 comes down
>> to whether or not the "IETF we" will be similarly willing.
>
> I am not convinced that a host being aggressive with initial cwnd (Li=
nux) would
> not end up unfairly monopolizing available bandwidth compared to olde=
r more conservative
> implementations (Windows). Whether fairness is important or not is an=
other debate.
>
>
