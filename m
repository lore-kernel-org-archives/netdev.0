From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT net] Open vSwitch
Date: Thu, 6 Feb 2014 09:09:41 +0200
Message-ID: <CAJZOPZK17fAaDfYj21i0F=cOg0uX52X9BPfdxZaExGyNTQqtdA@mail.gmail.com>
References: <1391583561-25399-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1391583561-25399-1-git-send-email-jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Wed, Feb 5, 2014 at 8:59 AM, Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
>
> A handful of bug fixes for net/3.14. High level fixes are:
>  * Regressions introduced by the zerocopy changes, particularly with
>    old userspaces.

Hi, so this post was the 2nd version of the five patches you posted
earlier, right? it would be very helpful if you
denote that on the subject line (e.g just use --subject-prefix="PATCH
net V1" for git format-patch) and provide
crash diff listing from V0. Also, on a related note to the patch that
deals with locking, I see these two smatch
complaints, which might be false-positives, what's your thinking?

net/openvswitch/flow.c:127 ovs_flow_stats_get() warn: returning with
unbalanced local_bh_disable
net/openvswitch/flow.c:160 ovs_flow_stats_clear() warn: returning with
unbalanced local_bh_disable
