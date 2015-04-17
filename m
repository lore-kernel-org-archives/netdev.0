From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Fri, 17 Apr 2015 12:28:26 -0400
Message-ID: <20150417162826.GB16743@htj.duckdns.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
 <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sat, Apr 18, 2015 at 12:35:06AM +0900, Tetsuo Handa wrote:
> If the sender side can wait for retransmission, why can't we use
> userspace programs (e.g. rsyslogd)?

Because the system may be oopsing, ooming or threshing excessively
rendering the userland inoperable and that's exactly when we want
those log messages to be transmitted out of the system.  This will get
log out as long as timer and netpoll are running which is the case
under a lot of circumstances.

Thanks.

-- 
tejun
