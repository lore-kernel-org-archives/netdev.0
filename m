From: Paul Chavent <paul.chavent@fnac.net>
Subject: Packet mmap payload alignment.
Date: Sat, 31 Mar 2012 21:47:14 +0200
Message-ID: <4F775F42.5020406@fnac.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm playing with the packet mmap interface. After having success with SOCK_DGRAM, i would like to try SOCK_RAW packet mmap.

I would like to align my payload on 16 bytes boundary. On rx side, it's automatic. But on tx side, it lacks the possibility to tell to the kernel where to begin to read the data.

Do i miss something ?

Do you think it could be possible to have a "reserve" like on the rx side ?


Regards.

Paul.


P.S. : can you cc me your reply please ?
