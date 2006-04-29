From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: Re: [ROSE] Fix routing table locking in rose_remove_neigh.
Date: Sun, 30 Apr 2006 00:59:47 +0200
Message-ID: <4453EFE3.4070302@ccr.jussieu.fr>
References: <20060429133141.GA31820@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g19.free.fr ([212.27.42.28]:13736 "EHLO smtp2-g19.free.fr")
	by vger.kernel.org with ESMTP id S1750821AbWD2XAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2006 19:00:10 -0400
To: Ralf Baechle <ralf@linux-mips.org>
In-Reply-To: <20060429133141.GA31820@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Ralf Baechle wrote:
> The locking rule for rose_remove_neigh() are that the called needs to
> hold rose_neigh_list_lock, so we better don't take it yet again in
> rose_neigh_list_lock.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

All ROSE and HZ patches applied to kernel 2.6.16
Many thanks Ralf.

73 de Bernard, f6bvp

http://f6bvp.org
http://rose.fpac.free.fr/MINI-HOWTO/
http://rose.fpac.free.fr/MINI-HOWTO-FR/

