From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 04/11] net: bnx2x: convert to timecounter
 adjtime.
Date: Sun, 21 Dec 2014 20:01:49 +0100
Message-ID: <20141221190149.GA5676@localhost.localdomain>
References: <cover.1418504883.git.richardcochran@gmail.com>
 <976abf89c833c376c2666def2c60a7de0f020026.1418504889.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <976abf89c833c376c2666def2c60a7de0f020026.1418504889.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 21, 2014 at 07:46:59PM +0100, Richard Cochran wrote:
> This patch changes the driver to use the new and improved method
> for adjusting the offset of a timecounter.

BTW, I noticed that this driver does not serialize access to the
timecounter in any way, but probably it should. Ariel?

Thanks,
Richard
