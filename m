From: "arun" <akumar@omnesysindia.com>
Subject: SIOCETHTOOL history ?
Date: Tue, 6 May 2003 18:07:48 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <01f301c313cc$4e6cb8b0$243205c0@otp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 Hi,
 
 Can anyone of the veterans please help me out with a 
small code curiosity

Why does the SIOCETHTOOL ioctl need 
CAP_NET_ADMIN even for harmless commands  like 
GSET ?

Some sample drivers that I managed to download over the net
that supports SIOCETHTOOL  has comments like 

"no need to check for CAP_NET_ADMIN since that is already
present in net/core/dev.c".  (And sure enough it was there)

Why would such a blanket checking be present when this ioctl
is only an entry point for many sub commands ? 

I have used SIOCGMIIPHY before and it seemed not to require 
any su rights or capabilities. What's then the difference between these
2 ioctls that require more capabilities for SIOCETHTOOL ?

arun
