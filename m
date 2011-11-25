From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Fri, 25 Nov 2011 09:28:28 -0800
Message-ID: <20111125092828.706a2929@nehalam.linuxnetplumber.net>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<1322220276.1908.75.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org,
	Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, John-/PVsmBQoxgPKo9QCiBeYKEEOCMrvLtNR@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322220276.1908.75.camel@mojatatu>
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

On Fri, 25 Nov 2011 06:24:36 -0500
jamal <hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org> wrote:

> Most hardware bridges out there support all different modes:
> You can have learning in the hardware or defer it to user/control plane
> by setting some flags. You can have broadcasting done in hardware or
> defer to user space. 
> The mods i was thinking of is to bring the Linux bridge to have the 
> same behavior. You then need to allow netlink updates of bridge MAC
> table from user space. There may be weaknesses with the current bridging
> code in relation to Vlans that may need to be addressed.
> 
> [But my concern was not so much the bridge - because changes are needed
> in that case; it is the "match, actionlist" that is already in place
> that got to me.]

The bridge module is already overly complex. Rather than adding more
modes, it should be split into separate modules. If you look at macvlan,
you will see it is already a subset of to bridge. Another example of
this is the team driver which is really just a subset of the bonding
code.
