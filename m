From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: DaVinci platform unable to boot via NFS
Date: Fri, 15 Mar 2013 19:47:40 +0530
Message-ID: <51432D84.10202@ti.com>
References: <CA+V-a8sNLBi1zB942ZbK26POrzcq7oOpNW9yPG5dG_gX7ZZ1oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>,
	dlos <davinci-linux-open-source@linux.davincidsp.com>,
	LAK <linux-arm-kernel@lists.infradead.org>,
	<netdev@vger.kernel.org>
To: Prabhakar Lad <prabhakar.csengg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:53797 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753867Ab3COOSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Mar 2013 10:18:09 -0400
In-Reply-To: <CA+V-a8sNLBi1zB942ZbK26POrzcq7oOpNW9yPG5dG_gX7ZZ1oQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/2013 7:11 PM, Prabhakar Lad wrote:
> Hi Mugunthan,
>
> With 3.9 release I am not able to boot any davinci board via nfs, finally
> digging Into I found that there were recent changes for Ethernet davinci.
> Finally I reverting this to some safe commit I was able to boot via nfs.
> I reverted back as following:-
> git checkout  f9a8f83b04e0c362a2fc660dbad980d24af209fc  drivers/net/ethernet/ti/
>
> Can you please take a look at and fix it.
>
> Cheers,
> --Prabhakar Lad
> http://in.linkedin.com/pub/prabhakar-lad/19/92b/955
The issue is also reported in CPSW driver and is fixed already. I have
posted the patch for Davinci EMAC in the below link.

http://patchwork.ozlabs.org/patch/228003/

Regards
Mugunthan V N
