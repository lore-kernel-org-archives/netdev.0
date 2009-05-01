From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [PATCH] virtio_net: Cleanup command queue scatterlist usage
Date: Fri, 01 May 2009 16:43:14 -0600
Message-ID: <1241217794.9646.588.camel@2710p.home>
References: <20090426.233014.216353908.davem@davemloft.net>
	 <20090427154925.4771.63651.stgit@debian.lart>
	 <20090501.153301.42015656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, sfr@canb.auug.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090501.153301.42015656.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-05-01 at 15:33 -0700, David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Mon, 27 Apr 2009 09:50:03 -0600
> 
> > We were avoiding calling sg_init* on scatterlists passed
> > into virtnet_send_command to prevent extraneous end markers.
> > This caused build warnings for uninitialized variables.
> > Cleanup the code to create proper scatterlists.
> > 
> > Signed-off-by: Alex Williamson <alex.williamson@hp.com>
> 
> This patch does not apply even to Linus's current tree.

It was against net-next-2.6.git, I'll update it for linux-2.6.git.
IIRC, it applied with some fuzz.

Alex
