From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 19/39] net/dev: replace schedule_timeout() with msleep()
Date: Tue, 8 Feb 2005 16:52:09 -0800
Message-ID: <20050208165209.0481fb9d.davem@davemloft.net>
References: <20050120235352.GH2600@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org,
	kernel-janitors@lists.osdl.org
To: Nishanth Aravamudan <nacc@us.ibm.com>
In-Reply-To: <20050120235352.GH2600@us.ibm.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 20 Jan 2005 15:53:52 -0800
Nishanth Aravamudan <nacc@us.ibm.com> wrote:

> Description: Use msleep() instead of schedule_timeout() to guarantee the task
> delays as expected. The current code uses TASK_INTERRUPTIBLE, but does not
> respond to signals, so msleep() should be ok.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>

Applied, thanks Nishanth.
