From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/1] drivers: net: cpsw: Prevent NUll pointer
 dereference with two PHYs
Date: Tue, 19 Apr 2016 10:44:15 -0700
Message-ID: <57166E6F.90905@gmail.com>
References: <1461074186-25535-1-git-send-email-andrew.goodbody@cambrionix.com>
 <1461074186-25535-2-git-send-email-andrew.goodbody@cambrionix.com>
 <57164383.6080103@ti.com>
 <20160419110140.75e35c3c.drivshin.allworx@gmail.com> <57165269.40207@ti.com>
 <20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, mugunthanvnm@ti.com, tony@atomide.com,
	andrew@lunn.ch
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160419131443.7a3b3ef7.drivshin.allworx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19/04/16 10:14, David Rivshin (Allworx) wrote:
>> Ah Ok. There are no user of cpsw_platform_data outside of net/ethernet/ti/,
>> so yes, looks like your patch 1 does exactly what's needed.
> 
> Given that the v1 of Andrew's patch is already in Dave's net tree, and 
> would obviously have many conflicts with mine, how should I proceed? 
> Since you already requested Dave revert that patch, should I just wait 
> for that to happen and then resubmit my series? 
> 
> Dave, Does that sound good to you? 

At some point, it would be good for the cpsw driver to be moved to the
DSA subsystem, a lot of these tiny little details, like how to attach
the PHY to the internal, external, fixed MDIO bus have been solved
already using standard DT bindings. This leaves you with the fun part:
how to program your switch such that it works in response to the
networking stack sollicitations (bridge, VLAN, ethtool etc.).
-- 
Florian
