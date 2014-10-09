From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State 6 (pc6)onHaswell
 hardware: does the patch below against current kernel make a difference?
Date: Thu, 09 Oct 2014 14:02:45 +0200
Message-ID: <54367965.7010301@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <54359E9C.7060704@crashplan.pro> <20141008221726.GA25515@electric-eye.fr.zoreil.com> <5435BEC3.6080200@crashplan.pro> <20141008232655.GA26561@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hayes Wang <hayeswang@realtek.com>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:55971 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbaJIMCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 08:02:51 -0400
In-Reply-To: <20141008232655.GA26561@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu schreef op 09-10-14 om 01:26:
 > You are mixing 3.13 and 3.17. Try 'uname -r' alone. Got it ?
I think I have got it.

Francois Romieu schreef op 07-10-14 om 00:13:
 > Ceriel, does the patch below against current kernel make a difference?

Old r8169 "powertop --auto-tune && powertop" result:
C2 (pc2)   26.1%    |                     |
C3 (pc3)   73.6%    | C3 (cc3)    1.6%    | C3-HSW      1.6%  108.0 ms
C6 (pc6)    0.0%    | C6 (cc6)   98.3%    | C6-HSW     98.3%  194.9 ms
---
C2 (pc2)    0.0%    |                     |
C3 (pc3)   99.4%    | C3 (cc3)    0.0%    | C3-HSW      0.0%    0.0 ms
C6 (pc6)    0.0%    | C6 (cc6)   99.6%    | C6-HSW     99.6%  237.4 ms
---

New r8169 "powertop" result (even without --auto-tune):
C2 (pc2)    0.0%    |                     |
C3 (pc3)    9.9%    | C3 (cc3)    0.7%    | C3-HSW      0.7%   16.4 ms
C6 (pc6)   89.9%    | C6 (cc6)   99.2%    | C6-HSW     99.2%  223.2 ms
---
