From: satya srikanth <satyasrikanth2001@yahoo.com>
Subject: Re: gigabit ethernet
Date: Sat, 14 Feb 2004 06:09:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040214140914.3341.qmail@web21107.mail.yahoo.com>
References: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xiaoliang \(David\) Wei" <weixl@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
  The solution of using NAPI reduced packet drops to
some extent. I am using dual processor 2.0 GHz Xeon
Processors (32 bit 66 MHz PCI bus). For different
packet sizes maximum bandwidth that my receiver
handled without drops are like this. (Using raw
sockets)

Pkt Size   Max Bandwidth 
(bytes)       (Mbps)
--------   ------------
 100           200
 500           500
 1000          700         
 1500          900

My CPU is unable to handle anything more than this. Is
it possible to handle 1000Mbps for any packet size or
atleast something better than this by using more
powerful machines. If anyone of you have experimented
with this, can you give an idea of what kind of a
machine do I need for this. 
   Also my driver has IP checksum offloading option
ON. Does it mean that I can safely remove checksum
calculation in TCP/IP stack?

--- Cheng Jin <chengjin@cs.caltech.edu> wrote:
> NAPI for e1000 is off by default, you have to
> explicitly enable it
> in the kernel config file (CONFIG_E1000_NAPI).
> What kind of processors do you have?  I haven't
> tried pumping 1 Gbps
> using processors slower than 2.4G Xeons.  But it


__________________________________
Do you Yahoo!?
Yahoo! Finance: Get your refund fast by filing online.
http://taxes.yahoo.com/filing.html
