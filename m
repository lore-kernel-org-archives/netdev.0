From: bert hubert <ahu@ds9a.nl>
Subject: [alessandro.suardi@oracle.com: TCP window scaling still bad in 2.6.7-bk17]
Date: Sun, 4 Jul 2004 23:41:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040704214127.GA24721@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Probably worth looking at:

----- Forwarded message from Alessandro Suardi <alessandro.suardi@oracle.com> -----

Date: Sun, 04 Jul 2004 23:11:19 +0200
From: Alessandro Suardi <alessandro.suardi@oracle.com>
To: linux-kernel <linux-kernel@vger.kernel.org>
Subject: TCP window scaling still bad in 2.6.7-bk17
X-Mailing-List: linux-kernel@vger.kernel.org

I have a tcpdump and a description of what happens here

http://xoomer.virgilio.it/incident/tcpdump.out

with www.kernel.org, but I'm mostly shut off the entire 'net.

The _only_ site I found I can browse without disabling TCP
 window scaling is http://www.google.it.


My system:

 RedHat 9 base distro
 2.6.7-bk17 plus ACX100 out-of-kernel wireless driver (version
  0.2.0-pre8_plus_fixes_13) from acx100.sf.net
 built with binutils 2.15.91.0.1 and GCC 3.4.0

System behaved properly until 2.6.7-bk1, was bad since 2.6.7-bk7
 (haven't tried in-between kernels as I was on holiday).

I also tried walking up to my router and connecting via eth0
 instead of wlan0 (to rule out the wireless driver) - still the
 connection to www.kernel.org hangs (always -bk17).


I'm available for further digging, please CC: me on replies as I
 only read lkml from the USSG archives.


Thanks,

--alessandro

 "Practice is more important than theory. A _lot_ more important."
    (Linus Torvalds on lkml, 1 June 2004)


-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


----- End forwarded message -----

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
