From: "Xiaoning He" <xiaoning@docomolabs-usa.com>
Subject: Neighbor cache behavior
Date: Thu, 9 May 2002 16:06:37 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <000201c1f7ae$2c5c2110$4f6015ac@VAIO>
References: <20020503095402W.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: <netdev@oss.sgi.com>
In-Reply-To: <20020503095402W.yoshfuji@wide.ad.jp>
List-Id: netdev.vger.kernel.org

Hi all

Thank you for answering my previous question about the neighbor cache. I
have a couple of more questions regarding the neighbor cache. Would you
please give me some help? 

My understanding about the behavior of neighbor cache is that when a AR
receives a packet for a destination, it will 

Check NC
If match, send the packet
If not
	Multicast NS
	Wait for NA
	Send the packet

Is this the correct behavior?

If so, I have looked into the Linux kernel, however, I don't know where
in the Linux kernel the code will check the Neighbor. I tried to search
the function ndisc_send_ns() because I think that's the function who
will handle the sending the NS is there is no entry in the NC. However,
it doesn't help. 

Could anyone provide me with some hints?

Also, I think I really need to know the Linux Kernel so that I don't
need always ask this kind of question. Is there any good book and
tutorial available which can give me a overall picture about how to
program the networking program for both user-land and kernel in the
Linux?

Thank you so much for your help.

Xiaoning He
