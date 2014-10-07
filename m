From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell hardware
Date: Tue, 7 Oct 2014 22:16:15 +0200
Message-ID: <20141007201615.GA4398@zoreil.com>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <5433C33B.2060700@crashplan.pro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ceriel Jacobs <linux-ide@crashplan.pro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pulsar.zoreil.com ([83.167.33.49]:37454 "EHLO pulsar.zoreil.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbaJGUVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 16:21:30 -0400
Content-Disposition: inline
In-Reply-To: <5433C33B.2060700@crashplan.pro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ceriel Jacobs <linux-ide@crashplan.pro> :
> Francois Romieu schreef op 07-10-14 om 00:13:
[...]
> >Realtek's r8168 driver defaults to CONFIG_ASPM=1
> 
> # modinfo r8168 suggests the opposite (ASPM is disabled by default):
> version:        8.039.00-NAPI
> parm:           aspm:Enable ASPM. (int)

$ grep CONFIG_ASPM src/Makefile 
CONFIG_ASPM = y

$ less src/r8168_n.c
[...]
#ifdef CONFIG_ASPM
static int aspm = 1;
#else
static int aspm = 0;
#endif

[...]
> Francois, what do you mean with "current kernel", the latest Ubuntu mainline
> kernel or something different?

Sorry. I meant current mainline as seen from git but anything close like
v3.15.x, v3.16.y or v3.17.k should be fine (patch applies).

-- 
Ueimor
