From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2.6 0/7]: assorted fixes
Date: Sun, 03 Oct 2004 23:12:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41606B47.9040703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave.

following are 6 assorted fixes and one small cleanup patch.
You can pull all patches from bk://212.42.230.204/net-2.6
I'll send 2.4 versions later.

ChangeSet@1.2043.1.7, 2004-10-03 20:44:53+02:00, kaber@coreworks.de
  [VLAN]: Missing rtnl_unlock in register_vlan_device error path
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.6, 2004-10-03 20:43:32+02:00, kaber@coreworks.de
  [IPV6]: Fix free_netdev after failed alloc_netdev in sit_init
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.5, 2004-10-03 20:42:17+02:00, kaber@coreworks.de
  [IPV4]: Fix ipip_fb_tunnel_dev leak in ipip_fini
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.4, 2004-10-03 20:41:00+02:00, kaber@coreworks.de
  [IPV4]: Fix free_netdev after failed alloc_netdev in ipip_init
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.3, 2004-10-03 20:39:25+02:00, kaber@coreworks.de
  [IPV4]: Fix free_netdev after failed alloc_netdev in ipgre_init
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.2, 2004-10-03 20:29:51+02:00, kaber@coreworks.de
  [NET_SCHED]: Remove useless variable in tc_ctl_tfilter
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>

ChangeSet@1.2043.1.1, 2004-10-03 20:25:10+02:00, kaber@coreworks.de
  [NET_SCHED]: Fix module leak in tc_ctl_tfilter error path
 
  Signed-off-by: Patrick McHardy <kaber@trash.net>
