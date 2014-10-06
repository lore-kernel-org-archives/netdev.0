From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell hardware
Date: Mon, 6 Oct 2014 03:06:07 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
References: <542B3829.3010108@crashplan.pro>
 <20141005165920.GA21926@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Ceriel Jacobs <linux-ide@crashplan.pro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:58776 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751859AbaJFDG2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 23:06:28 -0400
In-Reply-To: <20141005165920.GA21926@electric-eye.fr.zoreil.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Monday, October 06, 2014 12:59 AM
[...]
> > With in-kernel r8169 module, only P-state package C3 (pc3) 
> > can be reached
> > when enabling ASPM.
> > 
> > Only after installing r8168 driver (and enabling ASPM), a 
> > Haswell Celeron
> > G1820/G1840 processer will enter package C6 state (pc6).
> 
> Vanilla kernel r8169 driver logs a message that contains an 
> "XID" string.
> Please grep for it in your dmesg so that I can narrow the search for 
> meaningful differences in Realtek's r8168 driver.

I don't sure if the following information is helpful. Besides, I remember the rtl_init_one()
would disable it.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=d64ec841517a25f6d468bde9f67e5b4cffdc67c7

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=4521e1a94279ce610d3f9b7945c17d581f804242
 
Best Regards,
Hayes
