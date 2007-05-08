From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Tue, 08 May 2007 09:28:37 -0400
Message-ID: <1178630917.4078.46.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902CA58E7@orsmsx414.amr.corp.intel.com>
	 <1178313748.7408.41.camel@johannes.berg>
	 <1178616837.3385.85.camel@debian.sh.intel.com>
	 <1178617538.18162.54.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	jgarzik@pobox.com, cramerj <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	davem@davemloft.net
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:38765 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934738AbXEHN2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 09:28:48 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1721976wxd
        for <netdev@vger.kernel.org>; Tue, 08 May 2007 06:28:47 -0700 (PDT)
In-Reply-To: <1178617538.18162.54.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-08-05 at 11:45 +0200, Johannes Berg wrote:
..

Sorry, I missed a lot of the discussions; I am busyed out and will try
to catchup later tonight. I have quickly scanned the emails and
I will respond backwards (typically the most effective
way to catchup with a thread).

As a summary, I am not against the concept of addressing per-ring flow
control. 
Having said that, i fully understand where DaveM and Stephen are coming
from. Making such huge changes to a critical region to support uncommon
hardware doesnt abide to the "optimize for the common" paradigm. That is
also the basis of my arguement all along. I also agree it is quiet
fscked an approach to have the virtual flow control. I think it is
driven by some marketing people and i dont really think there is a
science behind it. Switched (External) PCI-E which is supposed to be
really cheap and hit the market RSN has per-virtual queue flow control,
so that maybe where that came from. In any case, that is a digression. 
Peter, can we meet the goals you strive for and stick to the "optimize
for the common"? How willing are you to change directions to achieve
those goals?

> On Tue, 2007-05-08 at 17:33 +0800, Zhu Yi wrote:
> 
> > Jamal, as you said, the wireless subsystem uses an interim workaround
> > (the extra netdev approach) to achieve hardware packets scheduling. But
> > with Peter's patch, the wireless stack doesn't need the workaround
> > anymore. This is the actual fix.
> 

I dont believe wireless needs anything other than the simple approach i
described. The fact that there an occasional low prio packet may endup
going out first before a high prio due to the contention is
non-affecting to the overall results.

> Actually, we still need multiple devices for virtual devices? Or which
> multiple devices are you talking about here?
> 

Those virtual devices you have right now. They are a hack that needs to
go at some point.

cheers,
jamal

