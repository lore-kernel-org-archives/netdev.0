From: Ben Greear <greearb@candelatech.com>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 09 Mar 2005 15:09:33 -0800
Message-ID: <422F822D.9010707@candelatech.com>
References: <422F6C37.8090202@candelatech.com> <5fc59ff3050309140910f3e492@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
In-Reply-To: <5fc59ff3050309140910f3e492@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> Ben:
> 
> Are you using the e1000 that is included in the 2.6.11 kernel? ethtool
> -d eth? works fine for me. What else is different in your env?

I have patched the e1000 in my 2.6.11 kernel, but I see this -d problem
on other un-patched systems as well, so it can't be (just) my patches
that are the problem.

I also tried this on my x86-64 opteron system, running FC3.  I
have not hacked up this kernel or user-space tools at all :)

[root@grok lanforge]# ethtool -i eth3
driver: e1000
version: 5.5.4-k2-NAPI
firmware-version: N/A
bus-info: 0000:02:08.0
[root@grok lanforge]# ethtool -d eth3
Cannot dump registers: Success
[root@grok lanforge]# uname -a
Linux grok 2.6.10-1.766_FC3smp #1 SMP Wed Feb 9 23:17:48 EST 2005 x86_64 x86_64 x86_64 GNU/Linux


I'm using ethtool 1.8 on this system.


What version of ethtool are you using?


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
