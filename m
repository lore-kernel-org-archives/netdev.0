From: Daniel Schaffrath <daniel.schaffrath@mac.com>
Subject: No cmsg for SOCK_STREAM?
Date: Sat, 14 Jul 2007 11:53:20 +0200
Message-ID: <C63E4CE2-57E4-446C-B7B0-80D9E506A83C@mac.com>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-net@vger.kernel.org, Linux NetDev <netdev@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello everybody,

'man 7 ip' sais that IP_RECVOPTS is not supported for SOCK_STREAM  
sockets.

But what if for debugging/measuring purposes I wanted to record the  
route of the datagrams containing the stream segments? Are there any  
other ways to get the IP options? Like a second raw socket to deliver  
cmsgs to user space and later resubmit for kernel TCP processing and  
normal delivery to application -- if that is possible at all.

Or any other way?

Thanks in advance,
Daniel



