From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 12/14] mlx4: use netdev_rss_key_fill() helper
Date: Sat, 22 Nov 2014 20:14:33 -0800
Message-ID: <1416716073.17888.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1416715651.7215.43.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:52829 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891AbaKWEOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 23:14:36 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so7198689ier.0
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 20:14:35 -0800 (PST)
In-Reply-To: <1416715651.7215.43.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-23 at 04:07 +0000, Ben Hutchings wrote:

> It's introduced by the above patch, as you seem to have worked out.
> Drivers not implementing ethtool_ops::get_rxfh_key_size will always get
> a non-null indir pointer (see commit 61d88c6811f2).

Yep, thanks Ben ;)
