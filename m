From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: jumbo on 8169
Date: Mon, 27 Dec 2004 17:38:02 +0100
Message-ID: <20041227163802.GA27692@electric-eye.fr.zoreil.com>
References: <41CFF27A.2070008@inet.it> <20041227123136.GA25187@electric-eye.fr.zoreil.com> <41D01562.4090606@inet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <200412271747.iBRHl0CM028784@electric-eye.fr.zoreil.com>
To: Luca Bortot <l.bortot@inet.it>
Content-Disposition: inline
In-Reply-To: <41D01562.4090606@inet.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luca Bortot <l.bortot@inet.it> :
[...]
> based on a simple tcp test I made (writes zeroes to a socket in 32Kb 
> blocks and prints the write speed), these are the results (win box cpu 
> not reported - always under 10% load):
> 
> BEFORE PATCH (mtu 1500)
> speed ~38 MB/s
> cpu idle 10%
> cpu system 90%
> 
> AFTER PATCH (mtu 7000)
> speed ~45MB/s
> cpu idle 40%
> cpu system 60%

TSO may make a difference for a TCP test. See ethtool help to enable it.
You can experiment with Tx csum/SG as well.

I'll welcome a complete dmesg and lspci -vx as they pretty well describe
the working combinations.

--
Ueimor
