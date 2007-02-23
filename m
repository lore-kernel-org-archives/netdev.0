From: Kristian Evensen <kristrev@ifi.uio.no>
Subject: Is the TCP-code threaded?
Date: Sat, 24 Feb 2007 01:38:59 +0200
Message-ID: <45DF7B13.6040407@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-net@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I have been looking quite deeply into the TCP-code, but there is one 
thing I simply dont manage to understand. Can the code process more than 
one skb on a socket at the time, or is it strictly one and one?

E.g say that you are going to send something (an skb), and you recieve 
an ack at the same time. Will the kernel finish whatever of the two 
comes first (say, finish sending) or can it, in the middle of treating 
the new packet to send, do a switch and process the ack?

Thanks,
Kristian
