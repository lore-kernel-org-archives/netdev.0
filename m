From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v10] openvswitch: enable NSH support
Date: Tue, 26 Sep 2017 13:05:34 +0200
Message-ID: <20170926130534.170270e3@griffin>
References: <1506401236-5716-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e@erig.me, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1506401236-5716-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Tue, 26 Sep 2017 12:47:16 +0800, Yi Yang wrote:
> +	return ((ret != 0) ? false : true);

I'm not going to review this version but this caught my eye - I pointed
out this silly construct in my review of v9. I can understand that
working late in the night and rewriting the code back and forth, one
could end up with such construct and overlook it at the final
self-review before submission. Happens to everyone.

But leaving this after a review pointed it out means you're not paying
enough attention to your work. Even the fact that you sent v10 so
shortly after v9 means you did not spend the needed time on reflecting
on the review and that you did not properly test the new version. And
I told you exactly this before.

Honestly, I'm starting to be tired with reviewing your patch again and
again and pointing out silly mistakes like this one and repeating basic
things to you again and again.

 Jiri
