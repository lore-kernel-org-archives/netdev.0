From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 0/5] drivers: net: usb: rtl8150: bug fixing and code
 cleanup
Date: Sat, 18 May 2013 23:20:13 +0200
Message-ID: <20130518212013.GA26921@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1305182305110.16874@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305182305110.16874@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petko Manolov <petkan@nucleusys.com> :
[...]
> This patch series adds rtl8150.h, which contains structure and constant 
> definitons formerly found in rtl8150.c, removes socket buffer 
> pre-allocated pool and uses dynamically allocated memory for the 
> asynchronous URB requests, thus avoids clobbering the previously scheduled 
> for update value.
> 
> This patch series is against 'net' tree.

'net' tree takes fixes. The cleanup / fix ratio is imho a bit high
in this series. You may submit the fix part now and wait until
davem merges 'net' into 'net-next' to submit big cleanups against
net-next.

-- 
Ueimor
