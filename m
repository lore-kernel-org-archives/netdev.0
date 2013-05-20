From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 1/5] drivers: net: usb: rtl8150: moving constant and
 structure definitions out of rtl8150.c
Date: Mon, 20 May 2013 22:08:32 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305202158520.3400@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305182306550.16874@fry.nucleusys.com> <1369061360.4616.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369061360.4616.0.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 May 2013, Ben Hutchings wrote:

> Now how is this driver going to compile, when rtl8150.h is only added by
> the next patch?!

I got carried away by the desire to make each patch smaller and to the 
point.  Sacrificing build-ability of the tree, however, does not justify 
it.  My bad.

> You need to squash these first 2 together, so that the driver can be
> compiled after each step.

Will do once David merge 'net' into 'net-next'.


		Petko
