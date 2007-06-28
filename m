From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 patches
Date: Thu, 28 Jun 2007 23:10:37 +0200
Message-ID: <20070628211036.GA4233@electric-eye.fr.zoreil.com>
References: <20070628090054.GH4838@atlas.linux2go.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Soren Hansen <soren@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38888 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759878AbXF1VNm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 17:13:42 -0400
Content-Disposition: inline
In-Reply-To: <20070628090054.GH4838@atlas.linux2go.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(netdev Cced. People, please, please Cc: netdev)

Soren Hansen <soren@ubuntu.com> :
[...]
> I have an Asrock ConRoe945G-DVI motherboard with a RTL8111/8168B in it.
> The stock r8159 driver locks up from time to time. I've described it
> here: https://launchpad.net/bugs/121815 . The patchset at
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc3/ seems to fix it.
> Can you explain why the patchset is not in the mainline kernel?

1. thanks for the report
2. increase net.core.wmem_max, ping -f -q -l xx -s yy with xx and yy
   big enough and the driver will _still_ stop receiving/transmitting :o(
3. if I take the time to write a nice message to tell you why, it will
   delay me:
   - publishing an updated patchset against -rc6 that can handle davem's
     git-net with minor pain for akpm
   - preparing a serie for Jeff
   - answering the rot^Wpending r8169 reports

-- 
Ueimor
