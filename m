From: Jeff Garzik <jgarzik@mandrakesoft.com>
Subject: FreeBSD attempts NAPI...
Date: Sun, 16 Jun 2002 18:31:06 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D0D11AA.7070406@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip from release notes]

Selected network drivers now implement a semi-polling mode, which makes 
systems much more resilient to attacks and overloads. To enable polling, 
the following options are required in a kernel configuration file:

     options DEVICE_POLLING
     options HZ=1000 # not compulsory but strongly recommended

The kern.polling.enable sysctl variable will then activate polling mode; 
with the kern.polling.user_frac sysctl indicating the percentage of CPU 
time to be reserved for userland. The devices initially supporting 
polling are dc(4), fxp(4), rl(4), and sis(4). More details can be found 
in the polling(4) manual page.

[end snip]
