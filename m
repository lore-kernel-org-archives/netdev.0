From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [patch 2/2] tulip: NatSemi DP83840A PHY fix
Date: Sun, 25 Jun 2006 15:22:33 +0200
Message-ID: <7d01f9f00606250622k72f805a1h8dfdc9cfcf58cfd5@mail.gmail.com>
References: <200606250845.k5P8j3GU020832@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: val_henson@linux.intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, grundler@parisc-linux.org,
	jgarzik@pobox.com, kyle@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0102.google.com ([64.233.162.197]:12483 "EHLO
	nz-out-0102.google.com") by vger.kernel.org with ESMTP
	id S1750840AbWFYNWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 09:22:34 -0400
Received: by nz-out-0102.google.com with SMTP id o37so598742nzf
        for <netdev@vger.kernel.org>; Sun, 25 Jun 2006 06:22:33 -0700 (PDT)
To: "akpm@osdl.org" <akpm@osdl.org>
In-Reply-To: <200606250845.k5P8j3GU020832@shell0.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/25/06, akpm@osdl.org <akpm@osdl.org> wrote:
>
> From: Thibaut VARENE <T-Bone@parisc-linux.org>
>
> Fix a problem with Tulip 21142 HP branded PCI cards (PN#: B5509-66001),
> which feature a NatSemi DP83840A PHY.
>
> Without that patch, it is impossible to properly initialize the card's PHY,
> and it's thus impossible to monitor/configure it.

This patch can now be dropped. There's a better fix from Kyle McMartin
in our cvs, and Val should have gotten it already.

HTH

T-Bone

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/
