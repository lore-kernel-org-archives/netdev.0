From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fwd: [rhashtable] WARNING: CPU: 0 PID: 10 at
 kernel/locking/mutex.c:570 mutex_lock_nested()
Date: Mon, 12 Jan 2015 12:42:16 +0000
Message-ID: <20150112124216.GA26570@casper.infradead.org>
References: <20150110194803.GA9033@wfg-t540p.sh.intel.com>
 <54B3259B.7080601@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, lkp@01.org,
	Netdev <netdev@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B3259B.7080601@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/15 at 09:38am, Ying Xue wrote:
> Hi Thomas,
> 
> I am really unable to see where is wrong leading to below warning
> complaints. Can you please help me check it?

Not sure yet. It's not your patch that introduced the issue though.
It merely exposed the affected code path.

Just wondering, did you test with CONFIG_DEBUG_MUTEXES enabled?
