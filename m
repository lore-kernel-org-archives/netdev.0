From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 0/3] lwtunnel: autoload of lwt modules
Date: Mon, 15 Feb 2016 15:42:00 +0000
Message-ID: <1455550923-23673-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Tom Herbert" <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jiri Benc <jbenc@redhat.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:62127 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751619AbcBOPmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:42:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lwt implementations using net devices can autoload using the
existing mechanism using IFLA_INFO_KIND. However, there's no mechanism
that lwt modules not using net devices can use.

Therefore, add the ability to autoload modules registering lwt
operations for lwt implementations not using a net device so that
users don't have to manually load the modules.

Robert Shearman (3):
  lwtunnel: autoload of lwt modules
  mpls: autoload lwt module
  ila: autoload module

 include/net/lwtunnel.h    |  4 +++-
 net/core/lwtunnel.c       | 32 ++++++++++++++++++++++++++++++++
 net/ipv6/ila/ila_common.c |  1 +
 net/mpls/mpls_iptunnel.c  |  1 +
 4 files changed, 37 insertions(+), 1 deletion(-)

-- 
2.1.4
