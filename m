From: Nguyen Dinh Nam <64vn@cardvn.net>
Subject: iproute2 fwmark feature request
Date: Tue, 18 Jan 2005 15:17:34 +0700
Message-ID: <41ECC61E.7060908@cardvn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello netdev,
There are 2^32 values for fwmark, it's a hugh number.
netfilter deal with it better than iproute2, particularly, there is an 
optional mask to apply to the fwmark before comparing it with some value 
(mark module of iptables). It's very helpful because we can use that 32 
bits to store several sub values at the same time.
So it'll be cool if the syntax is
SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark 
FWMARK[/MASK] ]
Regards,
Nam
