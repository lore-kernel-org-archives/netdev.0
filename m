From: Ying Xue <ying.xue@windriver.com>
Subject: Re: Fwd: [rhashtable] WARNING: CPU: 0 PID: 10 at kernel/locking/mutex.c:570
 mutex_lock_nested()
Date: Tue, 13 Jan 2015 15:50:22 +0800
Message-ID: <54B4CE3E.8020009@windriver.com>
References: <20150110194803.GA9033@wfg-t540p.sh.intel.com> <54B3259B.7080601@windriver.com> <20150112124216.GA26570@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <lkp@01.org>,
	Netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150112124216.GA26570@casper.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/12/2015 08:42 PM, Thomas Graf wrote:
> On 01/12/15 at 09:38am, Ying Xue wrote:
>> Hi Thomas,
>>
>> I am really unable to see where is wrong leading to below warning
>> complaints. Can you please help me check it?
> 
> Not sure yet. It's not your patch that introduced the issue though.
> It merely exposed the affected code path.
>
> Just wondering, did you test with CONFIG_DEBUG_MUTEXES enabled?
> 
> 

After I enable above option, I don't find similar complaints during my
testing.

Regards,
Ying
