From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3.11] genetlink: fix family dump race
Date: Mon, 12 Aug 2013 22:06:54 -0700 (PDT)
Message-ID: <20130812.220654.1384854931460655539.davem@davemloft.net>
References: <1375879163-2116-1-git-send-email-johannes@sipsolutions.net>
	<20130811.212942.413012801159758438.davem@davemloft.net>
	<1376297697.11514.8.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	tgraf@suug.ch, andrei.otcheretianski@intel.com,
	ilan.peer@intel.com, stable@vger.kernel.org, pshelar@nicira.com
To: johannes@sipsolutions.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1376297697.11514.8.camel@jlt4.sipsolutions.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 12 Aug 2013 10:54:57 +0200

> I think for the current code the fix would still be correct, I can
> change the commit message if you like.

I agree, please update the commit message and resubmit.

> For backporting, we'll have to check which tree has Pravin's change
> and which doesn't and change this accordingly, I suppose.

This is really tricky, because we'd need to also backport the fixes
for the regressions added by Pravin's change such as:

50754d2188b04a679a249fb57751542643a436e0
c74f2b2678f40b80265dd53556f1f778c8e1823f
