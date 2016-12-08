From: "Yang, Yi" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: fix VxLAN-gpe port
 can't be created in ovs compat mode
Date: Thu, 8 Dec 2016 20:01:50 +0800
Message-ID: <20161208120150.GA16029@cran64.bj.intel.com>
References: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
	<20161208095401.3e4054c9@griffin>
	<20161208105750.GA14898@cran64.bj.intel.com>
	<20161208123756.204af819@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161208123756.204af819@griffin>
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

On Thu, Dec 08, 2016 at 12:37:56PM +0100, Jiri Benc wrote:
> On Thu, 8 Dec 2016 18:57:51 +0800, Yang, Yi wrote:
> > So ovs out of tree modules need to adapt to upstream kernel, any
> > kernel-related changes must be accepted by Linux kernel at first.
> 
> I'm perfectly aware of that and I'm saying that your patch is
> unacceptable for upstream kernel. This is a long standing policy of the
> kernel: there's no way you can get a patch into the kernel to
> accommodate an out of tree kernel module. The policy is there for good
> reasons and as paradoxical as it may sound, it benefits the projects
> that employ out of tree modules in the long run.
> 
> If Open vSwitch wants to carry a non-upstream patch, it's its choice
> and we can have that discussion but that's not something to discuss on
> netdev@vger nor propose for net-next.
>
Jiri, according to your statement, we have to switch Linux 4.7 or above
if we want to use ovs VxLAN-gpe, Ubuntu 16.04 has had new kernel, but it
just use Linux kernel 4.4, you know Linux distributuions nerver uses the
latest stable Linux kernel because they have their own patches to
maintain, that will be a nightmare if they take the latest stable
kernel. You know RHEL also follows the same philosophy.

Current ovs master can be built on Ubuntu 14.04 which have Linux kernel
3.13, I think compatibility backward is very important, out of tree
modules are very important to ovs. If ovs installation will depend on
the latest kernel and force users to switch to new kernel, I believe it
nerver will be so popular in the industies.
