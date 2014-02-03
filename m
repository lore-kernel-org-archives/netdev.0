From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC PATCH] openvswitch: Use net_ratelimit in
	OVS_NLERR
Date: Mon, 03 Feb 2014 14:08:08 -0800
Message-ID: <1391465288.2538.1.camel@joe-AO722>
References: <1391389686-34303-1-git-send-email-jesse@nicira.com>
	<1391389686-34303-6-git-send-email-jesse@nicira.com>
	<1391410526.2784.9.camel@joe-AO722>
	<CAEP_g=_vvSPLt76VUE66XHJtgCW_05acn-r77PfkJFWBkT0S2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org" <dev-yBygre7rU0SM8Zsap4Y0gw@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=_vvSPLt76VUE66XHJtgCW_05acn-r77PfkJFWBkT0S2A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Mon, 2014-02-03 at 13:46 -0800, Jesse Gross wrote:
> On Sun, Feb 2, 2014 at 10:55 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > Perhaps it'd make sense to use net_ratelimit()
> > instead of printk_once for OVS_NLERR
> 
> I guess I could see it going either way but I'm not sure I see a
> strong argument for changing.

pr_<level>_once is a per-site flag.

Some of these messages look as if seeing them
multiple times could be useful.
