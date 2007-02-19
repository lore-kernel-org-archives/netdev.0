From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: [PATCH 2/2][TCP] YeAH-TCP: limited slow start exported function
Date: Mon, 19 Feb 2007 11:35:09 +0100
Message-ID: <45D97D5D.9040101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:31607 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbXBSKfO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 05:35:14 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2385117nfa
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 02:35:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Angelo P. Castellani <angelo.castellani@gmail.con>

RFC3742: limited slow start

See http://www.ietf.org/rfc/rfc3742.txt

Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>
---

To allow code reutilization I've added the limited slow start procedure 
as an exported symbol of linux tcp congestion control.

On large BDP networks canonical slow start should be avoided because it 
requires large packet losses to converge, whereas at lower BDPs slow 
start and limited slow start are identical. Large BDP is defined through 
the max_ssthresh variable.

I think limited slow start could safely replace the canonical slow start 
procedure in Linux.

Regards,
Angelo P. Castellani

p.s.: in the attached patch is added an exported function currently used 
only by YeAH TCP

 include/net/tcp.h   |    1 +
 net/ipv4/tcp_cong.c |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

