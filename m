From: David =?iso-8859-1?Q?H=E4rdeman?= <david@2gen.com>
Subject: Re: 2.4.29, e100 and a WOL packet causes keventd going mad
Date: Sun, 30 Jan 2005 18:18:49 +0100
Message-ID: <20050130171849.GA3354@hardeman.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261738AbVA3RTE@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I experience the same problems as reported by Michael Gernoth when 
sending a WOL-packet to computer with a e100 NIC which is already 
powered on.

In my case, it's running kernel 2.6.8.1 and the NIC is identified by 
lspci as:
0000:02:08.0 Ethernet controller: Intel Corp. 82562EZ 10/100 Ethernet 
Controller (rev 02)
or numerically:
0000:02:08.0 0200: 8086:1050 (rev 02)

The symptoms is that kacpid starts using all the CPU time it can, a 
shutdown takes 5 - 10 minutes after I've done this (in contrast to 20 - 
30 seconds when the machine is healthy).

Also, if I do a "shutdown -h" on the machine after sending a WOL packet 
when it's already powered up, it will shutdown and immediately start up 
again instead of powering off.

So, any suggestions on how to fix it?

Regards,
David

Please CC me on any replies.
