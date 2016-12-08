From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: fix VxLAN-gpe port
 can't be created in ovs compat mode
Date: Thu, 8 Dec 2016 12:37:56 +0100
Message-ID: <20161208123756.204af819@griffin>
References: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
	<20161208095401.3e4054c9@griffin>
	<20161208105750.GA14898@cran64.bj.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20161208105750.GA14898-re2EX8HDrk21gSHoDXDV2kEOCMrvLtNR@public.gmane.org>
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

On Thu, 8 Dec 2016 18:57:51 +0800, Yang, Yi wrote:
> So ovs out of tree modules need to adapt to upstream kernel, any
> kernel-related changes must be accepted by Linux kernel at first.

I'm perfectly aware of that and I'm saying that your patch is
unacceptable for upstream kernel. This is a long standing policy of the
kernel: there's no way you can get a patch into the kernel to
accommodate an out of tree kernel module. The policy is there for good
reasons and as paradoxical as it may sound, it benefits the projects
that employ out of tree modules in the long run.

If Open vSwitch wants to carry a non-upstream patch, it's its choice
and we can have that discussion but that's not something to discuss on
netdev@vger nor propose for net-next.

 Jiri
