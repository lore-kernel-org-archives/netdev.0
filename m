From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH v2 5/6] ath6kl: convert ath6kl_dbg() and ath6kl_dbg_dump()
 into functions
Date: Fri, 6 Jan 2012 10:14:17 +0200
Message-ID: <4F06AD59.3050207@qca.qualcomm.com>
References: <20120105132523.22281.95999.stgit@x201>	 <20120105132834.22281.78822.stgit@x201> <1325781489.22154.19.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <sfr@canb.auug.org.au>,
	<netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-next@vger.kernel.org>,
	<ath6kl-devel@qualcomm.com>, <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1325781489.22154.19.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On 01/05/2012 06:38 PM, Joe Perches wrote:
> On Thu, 2012-01-05 at 15:28 +0200, Kalle Valo wrote:
> 
>> diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
> []
>> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...)
> []
>> +	ath6kl_printk(KERN_DEBUG, "%pV", &vaf);
> [
>> diff --git a/drivers/net/wireless/ath/ath6kl/debug.h b/drivers/net/wireless/ath/ath6kl/debug.h
> []
>> +void ath6kl_dbg(enum ATH6K_DEBUG_MASK mask, const char *fmt, ...);
> 
> You need to add
> 
> __printf(2, 3)
> 
> to the prototype.
> 
> If it's not there, the printf formats and arguments aren't verified.
> %pV could do the wrong/bad things.

Nice, I'll add that to v3. Thanks again.

Kalle
