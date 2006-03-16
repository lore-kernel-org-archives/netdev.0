From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH]: e1000 endianness bugs
Date: Thu, 16 Mar 2006 07:31:41 +0000
Message-ID: <20060316073141.GA29074@infradead.org>
References: <20060315.142628.28661597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff@garzik.org, cramerj@intel.com, john.ronciak@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752226AbWCPHbo@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060315.142628.28661597.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 15, 2006 at 02:26:28PM -0800, David S. Miller wrote:
> 
> 	return -E_NO_BIG_ENDIAN_TESTING;
> 
> [E1000]: Fix 4 missed endianness conversions on RX descriptor fields.

Could the e1000 maintainers please add endianess annotations so that
sparse will catch such things in the future?
