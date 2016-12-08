From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: fix VxLAN-gpe port
 can't be created in ovs compat mode
Date: Thu, 8 Dec 2016 09:54:00 +0100
Message-ID: <20161208095401.3e4054c9@griffin>
References: <1481185210-13056-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1481185210-13056-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Thu,  8 Dec 2016 16:20:10 +0800, Yi Yang wrote:
> In ovs compat mode, ovs won't use LWT in current kernel, this is to
> make sure ovs can work on the old kernels, Linux kernel v4.7 includes
> VxLAN-gpe support but many Linux distributions' kernels are odler than
> v4.7, this fix will ensure that ovs can create VxLAN-gpe port correctly
> on old kernels, it has been verified on Ubuntu 16.04 x86_64 with Linux
> kernel 4.4.0-53-generic.

NAK. We do have a way to configure this and that's rtnetlink. Open
vSwitch should use that to configure tunnels. Out of tree modules are
on their own. Upstream kernel does not accommodate out of tree modules.

 Jiri
