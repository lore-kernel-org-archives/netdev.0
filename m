From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Fri, 15 Mar 2013 08:35:24 -0400 (EDT)
Message-ID: <20130315.083524.1244515166306242265.davem@davemloft.net>
References: <1363257652-8255-1-git-send-email-kapranoff@inbox.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org
To: kapranoff@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363257652-8255-1-git-send-email-kapranoff@inbox.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Kapranov <kapranoff@inbox.ru>
Date: Thu, 14 Mar 2013 14:40:52 +0400

> @@ -867,7 +821,6 @@ void phy_state_machine(struct work_struct *work)
>  				netif_carrier_on(phydev->attached_dev);
>  			} else {
>  				if (0 == phydev->link_timeout--) {
> -					phy_force_reduction(phydev);
>  					needs_aneg = 1;
>  				}

This is not a single-statement basic block, and therefore you
should remove the surrounding braces.
