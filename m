From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Tue, 5 May 2009 12:51:52 +0930
Message-ID: <200905051251.53271.rusty@rustcorp.com.au>
References: <20090426.233014.216353908.davem@davemloft.net> <20090427154925.4771.63651.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: Alex Williamson <alex.williamson@hp.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090427154925.4771.63651.stgit@debian.lart>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 28 Apr 2009 01:20:03 am Alex Williamson wrote:
> We were avoiding calling sg_init* on scatterlists passed
> into virtnet_send_command to prevent extraneous end markers.
> This caused build warnings for uninitialized variables.
> Cleanup the code to create proper scatterlists.
> 
> Signed-off-by: Alex Williamson <alex.williamson@hp.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.
