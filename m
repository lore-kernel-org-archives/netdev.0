From: Joerg Roedel <joro-lkml@zlug.org>
Subject: [PATCH 02/02 V3] net/ipv6: seperate sit driver to extra module (addrconf.c changes)
Date: Tue, 10 Oct 2006 17:39:08 +0200
Message-ID: <20061010153908.GB27455@zlug.org>
References: <20061010153745.GA27455@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:44901 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S932161AbWJJPjK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 11:39:10 -0400
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061010153745.GA27455@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch contains the changes to net/ipv6/addrconf.c to remove sit
specific code if the sit driver is not selected.

Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
