From: "Samuel Ortiz" <samuel@sortiz.org>
Subject: Re: Generic netlink interface help
Date: 24 May 2007 09:43:30 -0000
Message-ID: <84po8XY4.1179999810.5490870.samuel@sortiz.org>
References: <20070524085956.GP7089@enneenne.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: giometti@enneenne.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 25.mail-out.ovh.net ([213.186.37.103]:44172 "HELO
	25.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755366AbXEXJnf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 05:43:35 -0400
In-Reply-To: <20070524085956.GP7089@enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Rodolfo,

On 5/24/2007, "Rodolfo Giometti" <giometti@enneenne.com> wrote:

>Hello,
>
>I'm trying to use this new API for my LinuxPPS support but I have some
>difficulties in understanding the code!
>
>Looking at http://linux-net.osdl.org/index.php/Generic_Netlink_HOWTO
>is not clear... for example in line:
>
>   msg_head = genlmsg_put(skb, pid, seq, type, 0, flags, DOC_EXMPL_C_ECHO, 1);
>
>what "pid", "seq", "type" and "flags" stand for?
>
>It could be possible to have a little kernel module implementing the
>ECHO function as example to compile and test?
You could look at Johannes Berg 802.11 generic netlink implementation for
a good example (net/wireless/nl80211.c in John Linville's tree):
http://git.kernel.org/?p=linux/kernel/git/linville/wireless-dev.git;a=blob;f=net/wireless/nl80211.c;h=d6a44a386c2b86b81514b08d3c9b324dd2c7d229;hb=HEAD


>Again, I read in a message from Jamal Hadi Salim regarding Kernel <
>--> User space Communication that:
>
> Essentially nothing new, Communication is as in standard netlink
> approach.  i.e from user space you open a netlink socket to the
> kernel - in this case family NETLINK_GENERIC - and send and receive
> response as well as asynchronous events.  To receive to events you
> subscribe to specific multicast groups.
>
>So I suppose I can modify a little my userland programs using old API
>in order to support this new API. Is that right?
You probably want to use the libnl library. The latest SVN code has
support for generic netlink:
http://people.suug.ch/~tgr/libnl/

Cheers,
Samuel.
