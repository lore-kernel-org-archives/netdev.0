From: Andy Lutomirski <luto@stanford.edu>
Subject: Re: [PATCH r8169] ethtool support and sane speed selection/detection
Date: Mon, 26 Apr 2004 10:41:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <408D49BF.40708@stanford.edu>
References: <OFF82CB6DE.E6133152-ON87256E81.007259F5-86256E81.0073C48D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@myrealbox.com>, netdev@oss.sgi.com,
        romieu@fr.zoreil.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
In-Reply-To: <OFF82CB6DE.E6133152-ON87256E81.007259F5-86256E81.0073C48D@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason wrote:
> Hey Andy,
> I hand patched my driver (which is probably my mistake), and I noticed a 
> great increase in bring-up time.  Good job!

:)

> 
> I noticed that the new driver never logs my speed in the dmesg (like the 
> old driver did).  I could use ethtool, but I'm all about backwards 
> compatibility.  So, it might be a good idea to have it in there too.

OK.  It'll have to go in the timer, though, which means won't work if we 
kill the timer.  I'll wait until the driver stabilizes again so I don't 
just add one more patch with conflicts.

--Andy

> 
> Thanks,
> Jon
