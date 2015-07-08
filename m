From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: "primary_reselect" with "failure" is not
 working properly
Date: Wed, 08 Jul 2015 16:06:34 -0700 (PDT)
Message-ID: <20150708.160634.2087986100168064781.davem@davemloft.net>
References: <1436261690-1121-1-git-send-email-ranamazharp@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, gospo@cumulusnetworks.com,
	mazhar.rana@cyberoam.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sanket.shah@cyberoam.com
To: ranamazharp@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436261690-1121-1-git-send-email-ranamazharp@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mazhar Rana <ranamazharp@gmail.com>
Date: Tue,  7 Jul 2015 15:04:50 +0530

> From: Mazhar Rana <mazhar.rana@cyberoam.com>
> 
> When "primary_reselect" is set to "failure", primary interface should
> not become active until current active slave is down. But if we set first
> member of bond device as a "primary" interface and "primary_reselect"
> is set to "failure" then whenever primary interface's link get back(up)
> it become active slave even if current active slave is still up.
> 
> With this patch, "bond_find_best_slave" will not traverse members if
> primary interface is not candidate for failover/reselection and current
> active slave is still up.
> 
> Signed-off-by: Mazhar Rana <mazhar.rana@cyberoam.com>
> Signed-off-by: Jay Vosburgh <j.vosburgh@gmail.com>

Applied, thanks.
