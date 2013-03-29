From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH net-next 0/6] Open vSwitch updates
Date: Fri, 29 Mar 2013 14:46:46 +0100
Message-ID: <cover.1364563346.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
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

A couple of small Open vSwitch fixes and cleanups that accumulated
while working on larger pieces.

The biggest change is the exposure of <linux/openvswitch.h> to user
space to make the Netlink interface available without requiring every
appliation to copy the header file from a source tree.

Thomas Graf (6):
  openvswitch: Specify the minimal length of OVS_PACKET_ATTR_PACKET in
    the policy
  openvswitch: Use nla_memcpy() to memcpy() data from attributes
  openvswitch: Refine Netlink message size calculation and kill
    FLOW_BUFSIZE
  openvswitch: Move common genl notify code into ovs_notify()
  openvswitch: Use ETH_ALEN to define ethernet addresses
  openvswitch: Expose <linux/openvswitch.h> to userspace

 include/linux/openvswitch.h      | 432 +------------------------------------
 include/uapi/linux/Kbuild        |   1 +
 include/uapi/linux/openvswitch.h | 456 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/datapath.c       | 119 +++++-----
 net/openvswitch/flow.c           |   2 +-
 net/openvswitch/flow.h           |  21 --
 6 files changed, 530 insertions(+), 501 deletions(-)
 create mode 100644 include/uapi/linux/openvswitch.h

-- 
1.7.11.7
