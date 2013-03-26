From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Tue, 26 Mar 2013 12:59:13 -0400 (EDT)
Message-ID: <20130326.125913.1596841088076065473.davem@davemloft.net>
References: <1364304872-6408-1-git-send-email-kapranoff@inbox.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org
To: kapranoff@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364304872-6408-1-git-send-email-kapranoff@inbox.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kirill Kapranov <kapranoff@inbox.ru>
Date: Tue, 26 Mar 2013 17:34:32 +0400

> -					phy_force_reduction(phydev);
> +				if (0 == phydev->link_timeout--) 
                                                                ^^^^

Trailing whitespace, please remove.

Also, for whatever reason this patch didn't make it to the mailing
list, that's critical because we automate the tracking of patches by
catching the patch postings made to the list.
