From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Mon, 12 Sep 2005 15:14:21 -0400
Message-ID: <20050912191419.GB19644@tuxdriver.com>
References: <09122005104858.332@bilbo.tuxdriver.com> <4325CEAB.2050600@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	cramerj@intel.com, jesse.brandeburg@intel.com,
	ayyappan.veeraiyan@intel.com, mchan@broadcom.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932164AbVILTSA@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4325CEAB.2050600@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2005 at 02:53:31PM -0400, Jeff Garzik wrote:

> For e.g. e1000, are we sure that packets dropped by hardware are 
> accounted elsewhere?

The e100 and tg3 patches move the count of those frames to
rx_missed_errors.  e1000 and ixgb were already counting them there in
addition to rx_discards, so they were simply removed from rx_discards.
3c59x was counting other errors in rx_discards, so they were removed
from that count.

John
-- 
John W. Linville
linville@tuxdriver.com
