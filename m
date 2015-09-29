From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: fix error handling
Date: Tue, 29 Sep 2015 13:50:05 -0700 (PDT)
Message-ID: <20150929.135005.1004294019949634588.davem@davemloft.net>
References: <1443430188-32702-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com,
	m.szyprowski@samsung.com, rasesh.mody@qlogic.com,
	netdev@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443430188-32702-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Mon, 28 Sep 2015 10:49:48 +0200

> Several functions can return negative value in case of error,
> so their return type should be fixed as well as type of variables
> to which this value is assigned.
> 
> The problem has been detected using proposed semantic patch
> scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].
> 
> [1]: http://permalink.gmane.org/gmane.linux.kernel/2046107
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Applied, thanks.
