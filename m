From: Brad House <brad@mainstreetsoftworks.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Mon, 24 Nov 2003 13:21:31 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC24C2B.1030007@mainstreetsoftworks.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <3FC14058.4010600@mcve.com> <20031124004023.A1140@electric-eye.fr.zoreil.com> <3FC14AA3.9050009@mcve.com> <20031124090421.A4482@electric-eye.fr.zoreil.com> <3FC21843.2080805@mcve.com> <20031124184908.A9566@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brad House <brad@mcve.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031124184908.A9566@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes, I can do that.  These are the patches I applied:
-ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-test9-bk25-netdrvr-exp1.patch.bz2
-r8169-mac-phy-version.patch

I did not apply these patches below because your answer suggested that I
should not as per the e-mail on 11/23:

 >> cool. Did those previous patches you posted get merged into the
 >> current netdrvr-exp1, or do those need to be applied as well ?
 > It is built on top of 2.6.0-test9-bk27 + (latest) netdrvr-exp:

These are the patches _NOT_applied:
 From 11/20/03
-r8169-start-xmit-fixes.patch
-r8169-dma-api-tx-buffers.patch
-r8169-rx_copybreak.patch
 From 11/19/03
-r8169-dma-api-tx.patch
-r8169-dma-api-data-buffers.patch

Let me know where to begin, and I'll do it.

-Brad

Francois Romieu wrote:
> Brad House <brad@mcve.com> :
> [...]
> 
>>>2) vanilla 2.6.0-test9 does not work either.
>>
>>correct, but the system doesn't lock up with vanilla -test9,
>>dhcpcd just hangs, then will eventually return.
> 
> 
> I have fscked something then. Could you apply the patches in order to
> figure which one triggers the lock-up ?
> 
> --
> Ueimor
> 


-- 
-----------------------------
Brad House
Sr. Developer
Main Street Softworks, Inc.

brad@mainstreetsoftworks.com
(386) 462-9522 Ext. 112
-----------------------------
