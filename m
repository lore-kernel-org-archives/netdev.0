From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH 0/2] pktgen changes
Date: Tue, 05 May 2015 22:29:26 +0200
Message-ID: <20150505202730.8715.48527.stgit@ivy>
References: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031318AbbEEUgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 16:36:08 -0400
In-Reply-To: <1430457130-16003-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series introduce some pktgen changes

Patch01:
 Cleanup my own work when I introduced NO_TIMESTAMP.

Patch02:
 Took over patch from Alexei, and addressed my own concerns, as Alexie
 is too busy with other work, and this will provide an easy tool for
 measuring ingress path performance, which is a hot topic ATM.

 Changes were primarily user interface related.  Introduced a separate
 "xmit_mode" setting, instead of stealing one of the dev flags like
 Alexei did.

---

Alexei Starovoitov (1):
      pktgen: introduce xmit_mode 'rx_inject'

Jesper Dangaard Brouer (1):
      pktgen: adjust flag NO_TIMESTAMP to be more pktgen compliant


 Documentation/networking/pktgen.txt |    9 ++++
 net/core/pktgen.c                   |   87 +++++++++++++++++++++++++++++++++--
 2 files changed, 91 insertions(+), 5 deletions(-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
