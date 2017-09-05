From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Tue, 5 Sep 2017 10:36:12 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D787F5387@ESESSMB107.ericsson.se>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
	<20170831124516.0c5db686@griffin>
	<20170904080005.GA70767@cran64.bj.intel.com>
	<20170904124216.6db68e8c@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4E84@ESESSMB107.ericsson.se>
	<20170904151601.2f198a53@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4EEB@ESESSMB107.ericsson.se>
	<20170904161303.69624386@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D787F4F69@ESESSMB107.ericsson.se>
	<20170905114949.5849b75f@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "e@erig.me" <e@erig.me>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170905114949.5849b75f@griffin>
Content-Language: en-US
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

> From: Jiri Benc [mailto:jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org]

> > So what is the correct layout for MASKED_SET action with nested fields?
> > 1. All nested values, followed by all nested masks, or
> > 2. For each nested field value followed by mask?
> >
> > I guess alternative 1, but just to be sure.
> 
> It's 2. Alternative 1 breaks netlink assumptions, is ugly to implement
> and probably impossible to be properly validated.

OK. For outsiders this was far from obvious :-)

So, for OVS_ACTION_ATTR_SET_MASKED any nested attribute, no matter on which nesting level, must contain value directly followed by mask.

If that is the principle of handling masks in Netlink APIs, than we must adhere to it.

BR, Jan
