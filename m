From: jamal <hadi@cyberus.ca>
Subject: patchlet
Date: 28 Dec 2004 10:33:48 -0500
Message-ID: <1104248027.1100.110.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-6f9Mwp3iMWKucXOWo7fM"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-6f9Mwp3iMWKucXOWo7fM
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

James,

Attached a small patchlet that looked obvious - untested.

cheers,
jamal

--=-6f9Mwp3iMWKucXOWo7fM
Content-Disposition: attachment; filename=secp
Content-Type: text/plain; name=secp; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2610-bk1/security/selinux/nlmsgtab.c	2004/12/28 04:01:14	1.1
+++ 2610-bk1/security/selinux/nlmsgtab.c	2004/12/28 04:05:39
@@ -56,6 +56,9 @@
 	{ RTM_NEWTFILTER,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_DELTFILTER,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETTFILTER,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
+	{ RTM_NEWACTION,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_DELACTION,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
+	{ RTM_GETACTION,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_NEWPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
 	{ RTM_GETPREFIX,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },
 	{ RTM_GETMULTICAST,	NETLINK_ROUTE_SOCKET__NLMSG_READ  },

--=-6f9Mwp3iMWKucXOWo7fM--
