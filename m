From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [2.6 patch] fix bridge <-> ATM compile error
Date: Tue, 15 Mar 2005 18:25:08 +0100
Message-ID: <20050315172508.GQ3189__17069.8262438693$1110908759$gmane$org@stusta.de>
References: <20050315121930.GE3189@stusta.de> <20050315091305.3fc07561@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bridge@osdl.org, chas@cmf.nrl.navy.mil,
        linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.co,
        linux-kernel@vger.kernel.org
Resent-Message-ID: <20050315174106.GS3189@stusta.de>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050315091305.3fc07561@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 15, 2005 at 09:13:05AM -0800, Stephen Hemminger wrote:

> Given the #ifdef mess, perhaps bridge should have the hooks available
> independent of the configuration.

The problem is the other way round:
The bridge code accesses hooks in the ATM code.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
