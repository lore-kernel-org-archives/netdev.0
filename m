From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Mon, 12 Sep 2005 14:53:31 -0400
Message-ID: <4325CEAB.2050600@pobox.com>
References: <09122005104858.332@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	cramerj@intel.com, jesse.brandeburg@intel.com,
	ayyappan.veeraiyan@intel.com, mchan@broadcom.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932152AbVILSxg@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <09122005104858.332@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Some fixes to normalize how rx_dropped is calculated.  This is the
> product of a discussion on netdev on or about 18 August 2005 w/
> the subject '[RFC] stats: how to count "good" packets dropped by
> hardware?'
> 
> Patches for 3c59x, e1000, e100, ixgb, and tg3 to follow.

For e.g. e1000, are we sure that packets dropped by hardware are 
accounted elsewhere?

	Jeff
