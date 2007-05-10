From: Koon Wah Yick <kyick@alcatel-lucent.com>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 12:09:46 -0400
Message-ID: <464343CA.6090500@lucent.com>
References: <4641E945.3070902@lucent.com> <20070510084232.147e1d8f@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Koon Wah Yick <kyick@alcatel-lucent.com>, netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hoemail1.lucent.com ([192.11.226.161]:35557 "EHLO
	hoemail1.lucent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756120AbXEJQJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 12:09:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen:

Thank you for your response, I type in modinfo sch_netem

Here is what I got:

filename: /lib/modules/2.6.11-1.1369_FC4/kernel/net/sched/sch_netem.ko
license: GPL
vermagic: 2.6.11-1.l369_FC 686 REGPARM 4KSTACKS gcc-4.0
depends:
srcversion: BD4563861423428FF0D5918

when I try the following "tc" command with netem

> tc qdisc change dev eth0 root netem loss 0.1%

I got the error message
RTNETLINK answers: No such file or directory.

I downloaded the ipRoute2 packet, build and re-install.  Nothing change, same
problem.  I do "make xconfig" on my current kernel, see component netem is not
enable.  I enable it and re-build the kernel that does not work for me as well,
the new kenerl does not boot (there may be other problem in building it).  Is
there an easier way to enable NETEM?

Koon-Wah.


On 5/10/2007 11:42 AM, Stephen Hemminger wrote:
> On Wed, 09 May 2007 11:31:17 -0400
> Koon Wah Yick <kyick@alcatel-lucent.com> wrote:
> 
> 
>>Hi:
>>
>>My Linux box has CentOS5 installed.  But I could not run tc command with any
>>netem parameters in command line. as shown in web site
>>http://linux-net.osdl.org/index.php/Netem.  I suspect, Netem was either not part
>>of the installed OS or has not been enabled.  Can you tell how to verified?
>>When I type in "rpm -qa" I see only iproute-2.6.18-4.el5, do I need iproute2?
>>Can you tell me how to update my Linux kernel to include netem functionality.
>>Thanks,
>>
>>Koon-Wah.
>>
>>
>>-
>>To unsubscribe from this list: send the line "unsubscribe netdev" in
>>the body of a message to majordomo@vger.kernel.org
>>More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> modinfo sch_netem
> 


