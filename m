From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [ROSE] Fix routing table locking in rose_remove_neigh.
Date: Wed, 03 May 2006 23:26:29 -0700 (PDT)
Message-ID: <20060503.232629.107723262.davem@davemloft.net>
References: <20060429133141.GA31820@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pidoux@ccr.jussieu.fr,
	linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33460
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751409AbWEDG1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:27:08 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060429133141.GA31820@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Sat, 29 Apr 2006 14:31:41 +0100

> The locking rule for rose_remove_neigh() are that the called needs to
> hold rose_neigh_list_lock, so we better don't take it yet again in
> rose_neigh_list_lock.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks.
