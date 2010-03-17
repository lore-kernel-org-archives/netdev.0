From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/13] RDS bugfixes and cleanups
Date: Tue, 16 Mar 2010 21:18:50 -0700 (PDT)
Message-ID: <20100316.211850.45524025.davem@davemloft.net>
References: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rds-devel@oss.oracle.com
To: andy.grover@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58025
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751625Ab0CQES3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:18:29 -0400
In-Reply-To: <1268351407-7394-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Grover <andy.grover@oracle.com>
Date: Thu, 11 Mar 2010 15:49:54 -0800

> These patches are against net-next, please apply.

All applied, thanks Andy.

BTW:

+	/* Do not send cong updates to IB loopback */
+	if (conn->c_loopback
+	    && rm->m_inc.i_hdr.h_flags & RDS_FLAG_CONG_BITMAP) {
+		rds_cong_map_updated(conn->c_fcong, ~(u64) 0);
+		return sizeof(struct rds_header) + RDS_CONG_MAP_BYTES;
+	}
+

Be careful with operator precedence here.  Even if it's right,
probably better to add parenthesis just to sleep more easily
at night :-)

