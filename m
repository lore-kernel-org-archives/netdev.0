From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 22:46:50 +0000
Message-ID: <42224DDA.1010907@phekda.gotadsl.co.uk>
References: <42208D83.80803@phekda.gotadsl.co.uk> <42209C4E.6000800@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42209C4E.6000800@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Jeff Garzik wrote:
> Richard Dawe wrote:
[snip]
>> +static const char rtl8169_gstrings_stats[][ETH_GSTRING_LEN] = {
>> +    "tx_ok", "rx_ok", "tx_err", "rx_err",
>> +    "rx_fifo", "frame_align", "tx_ok_1col", "tx_ok_mcol",
>> +    "rx_ok_phys", "rx_ok_bcast", "rx_ok_mcast", "tx_abort",
>> +    "tx_underrun",
>> +};
> 
> 
> Don't needlessly reformat copied code.  It's one-string-per-line 
> intentionally, for ease of maintenance and ease of adding new strings.

OK, I'll fix that.

> Also, I don't see why you renamed this from ethtool_stats_keys[].

I didn't copy it directly. I started off with something that looked like 
the ethtool stats code from the e100 driver. Then I noticed that 8139cp 
did the right thing for r8169.

I'll rename it.

>> +    /* begin NIC statistics dump */
>> +    RTL_W32(StatsAddrHigh, tp->nic_stats_addr >> 32);
>> +    RTL_W32(StatsAddrLow, (tp->nic_stats_addr & 0xffffffff) | 
>> DumpStats);
>> +    RTL_R32(StatsAddrLow);
> 
> 
> This last RTL_R32() can be removed [from 8139cp too], because a flush 
> immediately follows anyway:
[snip]

OK, will do.

Thanks, bye, Rich =]

-- 
Richard Dawe [ http://homepages.nildram.co.uk/~phekda/richdawe/ ]

"You can't evaluate a man by logic alone."
   -- McCoy, "I, Mudd", Star Trek
