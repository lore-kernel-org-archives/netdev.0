From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Prevent false warning for lack of FC NPIV
Date: Fri, 18 Mar 2016 19:23:08 -0400 (EDT)
Message-ID: <20160318.192308.892810907603757455.davem@davemloft.net>
References: <1458064324-16487-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	linux-scsi@vger.kernel.org, andrew.patterson@hpe.com
To: Yuval.Mintz@qlogic.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1458064324-16487-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 15 Mar 2016 19:52:04 +0200

> Not all adapters have FC-NPIV configured. If bnx2fc is used with such an
> adapter, driver would read irrelevant data from the the nvram and log
> "FC-NPIV table with bad length..." In system logs.
> 
> Simply accept that reading '0' as the feature offset in nvram indicates
> the feature isn't there and return.
> 
> Reported-by: Andrew Patterson <andrew.patterson@hpe.com>
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied.
