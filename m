From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [ANNOUNCE] nf-hipac v0.8 released
Date: Thu, 26 Jun 2003 16:20:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EFB0143.7000606@hipac.org>
References: <200306252248.44224.nf@hipac.org> <1056634720.5423.83.camel@sonja>
Reply-To: Michael Bellion and Thomas Heinz <nf@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Egger <degger@fhm.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Daniel

You wrote:
>>     - libnfhipac: netlink library for kernel-user communication
> 
> Is this library actually usable for applications which need to control
> the firewall or is it equally braindead to libiptables?

The library _is_ intended to be used by other applications than
the nf-hipac userspace tool, too. It hides the netlink communication
from the user who is only required to construct the command
data structure sent to the kernel which contains at most one single
nf-hipac rule. This is very straightforward and the kernel returns
detailed errors if the packet is misconstructed.

Taking a look at nfhp_com.h and evt. nf-hipac.c gives you some clue
on how to build valid command packets.


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
