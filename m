From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Mon, 2 Nov 2015 10:10:50 -0500
Message-ID: <20151102151050.GA3036@ketchup.mtl.sfl>
References: <1446245805-24128-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151102150218.GC7963@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151102150218.GC7963@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On Nov. Monday 02 (45) 04:02 PM, Andrew Lunn wrote:
> On Fri, Oct 30, 2015 at 06:56:45PM -0400, Vivien Didelot wrote:
> > It's easy to forget to lock the smi_mutex before calling the low-level
> > _mv88e6xxx_reg_{read,write}, so add a assert_smi_lock function in them.
> > 
> > Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Acked-by: Andrew Lunn <andrew@lunn.ch>
> 
> 
> Since there is no followup fixes patch, i assume we actually have it
> correct at the moment?

Yes, this v2 contains the 2 fixups you mentioned (removing the inline
keyword and keep the dsa_host_dev_to_mii_bus call as is). Thus this
version is correct.

Thanks,
-v
