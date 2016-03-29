From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: initialize return rc to avoid returning garbage
Date: Tue, 29 Mar 2016 18:28:04 +0000
Message-ID: <CO2PR11MB0088C1D580858221F6554A6997870@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1459270850-16177-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Colin King <colin.king@canonical.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459270850-16177-1-git-send-email-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Colin Ian King <colin.king@canonical.com>
> 
> in the case where qed_slowpath_irq_req is not called, rc is not assigned and so
> qed_int_igu_enable will return a garbage value.
> Fix this by initializing rc to 0.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks Colin.
Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
