From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/2] net: phy: add ethtool_phy_{get|set}_link_ksettings
Date: Fri, 6 May 2016 16:41:33 -0700
Message-ID: <572D2BAD.8080606@gmail.com>
References: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, fugang.duan@nxp.com,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462576729-5932-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/05/16 16:18, Philippe Reynes wrote:
> The callback {get|set}_link_ksettings are often defined
> in a very close way. There are mainly two differences in
> those callback:
> - the name of the netdev private structure
> - the name of the struct phydev in the private structure
> 
> We add two defines ethtool_phy_{get|set}_link_ksettings
> to avoid writing severals times almost the same function.

This looks fine in principle, but then there is a whole ton of code that
could become like that in the kernel, I do not have any strong opinion
either way...
-- 
Florian
