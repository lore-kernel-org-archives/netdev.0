From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Enable netem in my Linux box
Date: Thu, 10 May 2007 09:57:38 -0700
Message-ID: <20070510095738.563a23bf@localhost>
References: <4641E945.3070902@lucent.com>
	<20070510084232.147e1d8f@freepuppy>
	<464343CA.6090500@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Koon Wah Yick <kyick@alcatel-lucent.com>, netdev@vger.kernel.org,
	"Yick, Koon Wah (Koon)" <kyick@homail.ho.lucent.com>
To: Koon Wah Yick <kyick@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:36798 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307AbXEJQ5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 12:57:47 -0400
In-Reply-To: <464343CA.6090500@lucent.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 May 2007 12:09:46 -0400
Koon Wah Yick <kyick@alcatel-lucent.com> wrote:

> Stephen:
> 
> Thank you for your response, I type in modinfo sch_netem
> 
> Here is what I got:
> 
> filename: /lib/modules/2.6.11-1.1369_FC4/kernel/net/sched/sch_netem.ko
> license: GPL
> vermagic: 2.6.11-1.l369_FC 686 REGPARM 4KSTACKS gcc-4.0
> depends:
> srcversion: BD4563861423428FF0D5918
> 
> when I try the following "tc" command with netem
> 
> > tc qdisc change dev eth0 root netem loss 0.1%
> 
> I got the error message
> RTNETLINK answers: No such file or directory.
> 

You want to use 'add' not 'change'.
The examples on the linux-net page are sequential, so the first one uses 'add'.
Later examples, then use change to alter parameters
