From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next v3 08/14] net: dsa: mv88e6xxx: rename
 smi_mutex to reg_lock
Date: Sat, 18 Jun 2016 22:20:07 +0200
Message-ID: <20160618202007.GC7172@lunn.ch>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
 <20160618000736.5598-9-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160618000736.5598-9-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 08:07:30PM -0400, Vivien Didelot wrote:
> The chip smi_mutex mutex is used to protect the access to the internal
> switch registers, not only the Multi-chip Addressing Mode, as commented.
> 
> Other registers access (like management frames) may use this mutex.
> 
> Since we will isolate SMI-specific pieces of code, avoid the confusion
> now by renaming smi_mutex to reg_lock. No functional changes here.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
