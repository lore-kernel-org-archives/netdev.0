From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] eicon: fix -Warray-bounds warning
Date: Thu, 02 Feb 2012 14:50:36 -0500 (EST)
Message-ID: <20120202.145036.1235867786947627132.davem@davemloft.net>
References: <1328188830-28133-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, dkukawka@suse.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, isdn@linux-pingi.de,
	bhutchings@solarflare.com, David.Laight@aculab.com
To: danny.kukawka@bisect.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328188830-28133-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Danny Kukawka <danny.kukawka@bisect.de>
Date: Thu,  2 Feb 2012 14:20:28 +0100

> Fix for a -Warray-bounds warning. mixer_notify_update() tries to
> write to ((CAPI_MSG *) msg)->info.facility_req.structs[3] while
> structs is defined as byte structs[1]. Set all 'structs' which are
> part of the typdefs in the info union to 'byte structs[0]'.
> 
> v2: set all info.*.structs to byte structs[0]
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Applied, thanks.
