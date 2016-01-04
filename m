From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/3] rsi: Delete unnecessary variable initialisations in
 rsi_send_mgmt_pkt()
Date: Mon, 4 Jan 2016 12:38:29 +0300
Message-ID: <20160104093829.GE5284@mwanda>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5687E203.1070404@users.sourceforge.net>
 <20160104092857.GD5284@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160104092857.GD5284@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Btw, GCC misses a lot of uninitialized variable bugs.  I have a Smatch
check which sometimes catches the bugs that GCC misses but you should
not rely on the tools here.  These patches need to be reviewed manually.

And the "goto err" before the initialization makes everything more
complicated (that's actually what caused the bug in this patch, in fact).

regards,
dan carpenter
