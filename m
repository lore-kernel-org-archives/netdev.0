From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: forcedeth: version 0.20 available
Date: Tue, 23 Dec 2003 10:19:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE80899.40400@colorfullife.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD7D@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102CBDD7D@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Feldman, Scott wrote:

>>version 0.20 of forcedeth (GPLed nvnet replacement for nForce 
>>on-board nics) for Linux 2.4 and 2.6 is available at 
>>http://www.hailfinger.org/carldani/linux/patch> es/forcedeth/
>>    
>>
>
>Carl-Daniel, I'm bored:
>
>* Consider prefixing function names unique prefix so driver is
>  not anonymous in backtraces.
>* remove_nic: use free_netdev rather than kfree.
>
Ups. My fault.

>* remove_nic: should check if(dev) before dereferencing?
>* remove_nic: check np->rx_ring before pci_free_consistent?
>
I think it cannot be NULL, but I'll double check it.


>* NAPI support would be nice instead of the do_nic_poll timer.
>
We are still guessing the meaning of some irq flags. Until we understand 
them, it's IMHO too dangerous to rely on masking the rx interrupts for 
rx processing. Additionally I"m not a big fan of NAPI.

ethtool is on my TODO list, but I don't know when I'll have the time to 
implement it.

--
    Manfred
