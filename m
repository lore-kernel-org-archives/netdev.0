From: Florian Zwoch <zwoch@backendmedia.com>
Subject: Re: 82540EM very slow on 2.6.0-test[45]
Date: Sun, 14 Sep 2003 19:23:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <bk286l$31r$1@sea.gmane.org>
References: <20030910233512.GB18056@rushmore>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20030910233512.GB18056@rushmore>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

rwhron@earthlink.net wrote:
> ftp'ing a multi-megabyte file gives about 16-20k/second
> throughput.  I first noticed this on 2.6.0-test4, but
> the slowness may have existed longer.   The destination
> machine was running Solaris 8.
> 

same behaviour confimed here. test5 and test4 (can not confirm on 
earlier). both suffer from real bad network send performance on the 
82540EM Gigabit Ethernet Controller (rev 02).

i did not test ftp but scp suffers from exactly the same mentioned 
above. scp from this device resulted in about 80k/s to a local linux 
2.4.x machine. scp to this device gives about 4.5mb/s.

samba copy between the two machines is fast in both directions.

irc dcc protocol stalls down to about 1k/s (host specific?).

nothing has changed between a normal operating 2.4.20 kernel. i suppose 
something is broken atm. i did not set up any specific duplex mode, but 
it is detected as 100 mbps full duplex - as expected (like the 2.4 kernel).

maybe someone can look into this?

--
Florian Zwoch
