From: Joe Stringer <joe-LZ6Gd1LRuIk@public.gmane.org>
Subject: Re: [PATCH 1/5] netlink: extended ACK reporting
Date: Thu, 13 Apr 2017 14:44:21 -0700
Message-ID: <CAPWQB7FWOcEen3SGyQtW7t2WpDNLE08JEdHeZHmM738J=Rur0g@mail.gmail.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
	<20170408174900.12820-2-johannes@sipsolutions.net>
	<20170408183440.GA1900@nanopsycho>
	<1491676621.5800.24.camel@sipsolutions.net>
	<20170408184008.GB1900@nanopsycho>
	<990b5610-a894-b3d2-d3a7-536dfd25adb8@cumulusnetworks.com>
	<1491805089.2455.3.camel@sipsolutions.net>
	<c0b35e6e-e5cb-25f6-7ccf-eec33ba39f3b@6wind.com>
	<1492090170.29526.1.camel@sipsolutions.net>
	<28b0d93a-7e96-f7eb-b140-afc9ad429c30@6wind.com>
	<1492111480.29526.7.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ovs dev <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>, Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
	David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
	Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1492111480.29526.7.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/04/2017 12:24, "Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:

> On Thu, 2017-04-13 at 16:05 +0200, Nicolas Dichtel wrote:
>
> > Sure. It was just to mention that attribute 0 exists somewhere.
> > The other 0 attribute is OVS_TUNNEL_KEY_ATTR_ID.
>
> That looks like some really awkward hand-grown parsing - with all these
> "struct ovs_len_tbl" looking almost like a policy, but not using that
> code?
>
> Seems like something somebody should take a hard look at and see if it
> can't use more standard infrastructure.
>

I think that OVS was doing some more elaborate validation than most users,
so over time we picked up a bunch of extra parsing code that layers on top
of nla_parse(). I took a look at trying to broaden this and make it useful
to other users a while ago, but when I posted there wasn't much interest
from others on it so I just moved on. Maybe it's about time to pick that
back up.
