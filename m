From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware: does the patch below against current kernel make a difference?
Date: Thu, 9 Oct 2014 01:26:55 +0200
Message-ID: <20141008232655.GA26561@electric-eye.fr.zoreil.com>
References: <542B3829.3010108@crashplan.pro>
 <20141005165920.GA21926@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
 <20141006221307.GB10936@electric-eye.fr.zoreil.com>
 <54359E9C.7060704@crashplan.pro>
 <20141008221726.GA25515@electric-eye.fr.zoreil.com>
 <5435BEC3.6080200@crashplan.pro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ceriel Jacobs <linux-ide@crashplan.pro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52362 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaJHX1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 19:27:06 -0400
Content-Disposition: inline
In-Reply-To: <5435BEC3.6080200@crashplan.pro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ceriel Jacobs <linux-ide@crashplan.pro> :
> The 3.13 source was installed using "apt-get source linux-source-3.13.0"
> 
> The patch hunk#2 failing issue is something in the "heredoc" notation (me
> trying to apply the patch without storing the patch lines as temporary input
> file). I am now using the temp file without any issue.
> 
> The next newly blocking issue is this:
> 
> # make -C /lib/modules/$(uname -r)/build M=$(pwd) modules
> make: Entering directory `/usr/src/linux-headers-3.17.0-031700rc7-generic'

You are mixing 3.13 and 3.17. Try 'uname -r' alone. Got it ?

Please get some pristine 3.17 sources - they're available on www.kernel.org -
and try again.

-- 
Ueimor
