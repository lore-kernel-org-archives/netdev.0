From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v4] Add TCP encap_rcv hook (repost)
Date: Mon, 23 Apr 2012 17:08:17 -0400 (EDT)
Message-ID: <20120423.170817.1103719420692884446.davem@davemloft.net>
References: <CAEP_g=_3om5aR=P0ffa9421KhvYYrMEeE33TNcCC9UV6+XVWAQ@mail.gmail.com>
	<20120423.161313.1582195533832554777.davem@davemloft.net>
	<CAEP_g=8EVOVgDaWnu3sd+qHxNZ7+ogjzBkuWvfVHNAqX2DRf=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, stephen.hemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8EVOVgDaWnu3sd+qHxNZ7+ogjzBkuWvfVHNAqX2DRf=g@mail.gmail.com>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Date: Mon, 23 Apr 2012 13:53:42 -0700

> On Mon, Apr 23, 2012 at 1:13 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
>> Date: Mon, 23 Apr 2012 13:08:49 -0700
>>
>>> Assuming that the TCP stack generates large TSO frames on transmit
>>> (which could be the local stack; something sent by a VM; or packets
>>> received, coalesced by GRO and then encapsulated by STT) then you can
>>> just prepend the STT header (possibly slightly adjusting things like
>>> requested MSS, number of segments, etc. slightly). =A0After that it's
>>> possible to just output the resulting frame through the IP stack like
>>> all tunnels do today.
>>
>> Which seems to potentially suggest a stronger intergration of the STT
>> tunnel transmit path into our IP stack rather than the approach Simon
>> is taking
> =

> Did you have something in mind?

A normal bonafide tunnel netdevice driver like GRE instead of the
openvswitch approach Simon is using.
