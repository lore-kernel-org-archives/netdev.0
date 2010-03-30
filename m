From: Holger Schurig <hs4233@mail.mn-solutions.de>
Subject: Re: [PATCH] net/wireless/libertas: do not call wiphy_unregister() w/o wiphy_register()
Date: Tue, 30 Mar 2010 08:49:07 +0200
Message-ID: <201003300849.07441.hs4233@mail.mn-solutions.de>
References: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dan Williams <dcbw@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Bing Zhao <bzhao@marvell.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Mack <daniel@caiaq.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269875658-3324-1-git-send-email-daniel@caiaq.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The libertas driver calls wiphy_unregister() without a prior
> wiphy_register() when a devices fails initialization. Fix this by
> introducing a private flag.

Nice.

However, I wonder: do we really need a private variable?  Does each driver 
introduce a private variable for this?
