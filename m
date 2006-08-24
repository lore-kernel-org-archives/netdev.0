From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Subject: [PATCH 0/3] secid reconciliation-v01: Repost patchset with updates
Date: Thu, 24 Aug 2006 12:50:34 -0500
Message-ID: <44EDE6EA.1090601@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, sds@tycho.nsa.gov, chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:13429 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1030443AbWHXRuu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 13:50:50 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following are the changes included in this patchset since the previous post:

- Use SELinux transition rules instead of precedence when reconciling the secid's
  making it flexible/policy-driven; xfrm secid would prevail by default.
- Change the naming of access vector perms to flow_in and flow_out.
- Make selinux_xfrm_sock_rcv_skb checks conditional on compat_net.
- Switch selinux_inet_conn_request to use secmark; cipso is still allowed to
  override secmark currently in this regard (will rely on Paul Moore at HP
  to bring cipso into the reconciliation path).

This patchset is relative to David Miller's net-2.6.19.git.

Please consider for inclusion in 2.6.19.
