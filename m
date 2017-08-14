From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Mon, 14 Aug 2017 12:47:42 +0200
Message-ID: <20170814124742.7c04b72c@griffin>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
	<20170811102418.6b1be4f7@griffin>
	<20170811084722.GA19968@cran64.bj.intel.com>
	<20170811111055.482bd42b@griffin>
	<79BBBFE6CB6C9B488C1A45ACD284F51961C427FE@SHSMSX103.ccr.corp.intel.com>
	<20170811114449.745c49c5@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D7273679A@ESESSMB107.ericsson.se>
	<20170811122256.2cec123e@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D72736EAE@ESESSMB107.ericsson.se>
	<20170814095117.056fdf96@griffin>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D727373EA@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
To: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D727373EA-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
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

On Mon, 14 Aug 2017 10:35:42 +0000, Jan Scheurich wrote:
> Is it worth to speculate on how a hypothetical future NSH version
> (with a different Version value in the Base header) might look like?

Absolutely. This is uAPI we're talking about and once merged, it's set
in stone. Whatever we come up with should allow future extensibility.

> If this should ever arise, we could introduce a new push_nsh_v2
> action.

Which would mean we failed with the design. We would have to maintain
two parallel APIs forever. This is not how the design should be made.

 Jiri
