From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Elimination the forced speed reduction algorithm.
Date: Fri, 15 Mar 2013 08:51:35 -0400 (EDT)
Message-ID: <20130315.085135.1979138622322564611.davem@davemloft.net>
References: <1363257652-8255-1-git-send-email-kapranoff@inbox.ru>
	<20130315.083524.1244515166306242265.davem@davemloft.net>
	<1363351729.2433.4.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kapranoff@inbox.ru, netdev@vger.kernel.org,
	bhutchings@solarflare.com, peppe.cavallaro@st.com,
	bruce.w.allan@intel.com, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363351729.2433.4.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Fri, 15 Mar 2013 05:48:49 -0700

> The phy code also uses non standard kernel style tests like
> 	if (CONSTANT == variable)
> instead of
> 	if (variable == CONSTANT)

Right, to trigger compile time errors when "=" is accidently used
instead of "==".

But the whole driver is like this already.
