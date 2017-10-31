From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v14] openvswitch: enable NSH support
Date: Tue, 31 Oct 2017 21:02:05 +0100
Message-ID: <20171031210205.1882d98d@redhat.com>
References: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
	<20171031195741.GR22092@dev-rhel7>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Eric Garver <e@erig.me>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20171031195741.GR22092@dev-rhel7>
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

On Tue, 31 Oct 2017 15:57:41 -0400, Eric Garver wrote:
> On Mon, Oct 30, 2017 at 09:29:34AM +0800, Yi Yang wrote:
> > +	if (WARN_ON(is_push_nsh && is_mask))
> > +		return -EINVAL;
> 
> OVS_NLERR() is probably more appropriate.

No, not here. If this happens, it's a bug in the kernel and WARN_ON is
what we need. This is not triggerable from user space and user space
has no way to fix it if this happens.

 Jiri
