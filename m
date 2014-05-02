From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] introduce devm_mdiobus_alloc/free and clean up
 davinci mdio
Date: Fri, 02 May 2014 16:17:47 -0400 (EDT)
Message-ID: <20140502.161747.121619975003852704.davem@davemloft.net>
References: <1398860616-6612-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	rdunlap@infradead.org, jic23@kernel.org, santosh.shilimkar@ti.com,
	nsekhar@ti.com, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	sergei.shtylyov@cogentembedded.com, prabhakar.csengg@gmail.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398860616-6612-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Wed, 30 Apr 2014 15:23:32 +0300

> Introduce a resource managed devm_mdiobus_alloc[_size]()/devm_mdiobus_free()
> to automatically clean up MDIO bus alocations made by MDIO drivers,
> thus leading to simplified MDIO drivers code.
> 
> Clean up Davinci MDIO driver and use new devm API.
> 
> Changes in v3:
> - added devm_mdiobus_alloc_size() and
>   devm_mdiobus_alloc() converted to be just a simple wrapper now.
> 
> Changes in v2:
> - minor comments taken into account
> - additional patches added for cleaning up Davinci MDIO driver

Series applied to net-next, thanks.
