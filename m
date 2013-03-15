From: Kirill Kapranov <kapranoff@inbox.ru>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Fri, 15 Mar 2013 18:15:53 +0400
Message-ID: <1363356953.2890.13.camel@kkk.nita.ru>
References: <1363257652-8255-1-git-send-email-kapranoff@inbox.ru>
	 <20130315.083524.1244515166306242265.davem@davemloft.net>
Reply-To: kapranoff@inbox.ru
Mime-Version: 1.0
Content-Type: text/plain; charset="KOI8-R"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, joe@perches.com, bruce.w.allan@intel.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130315.083524.1244515166306242265.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


15/03/2013 08:35 -0400, David Miller wrote:
> From: Kirill Kapranov <kapranoff@inbox.ru>
> Date: Thu, 14 Mar 2013 14:40:52 +0400
> 
> > @@ -867,7 +821,6 @@ void phy_state_machine(struct work_struct *work)
> >  				netif_carrier_on(phydev->attached_dev);
> >  			} else {
> >  				if (0 == phydev->link_timeout--) {
> > -					phy_force_reduction(phydev);
> >  					needs_aneg = 1;
> >  				}
> 
> This is not a single-statement basic block, and therefore you
> should remove the surrounding braces.

Thank You, the excess braces will be removed.
