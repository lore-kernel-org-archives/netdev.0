From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2008-07-14
Date: Wed, 16 Jul 2008 13:00:07 -0700 (PDT)
Message-ID: <20080716.130007.11761812.davem@davemloft.net>
References: <20080714192302.GA2541@tuxdriver.com>
	<20080714.204532.116542087.davem@davemloft.net>
	<1ba2fa240807160549u68d9ecby25e79d832d772a0a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: tomasw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55627
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757056AbYGPUAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 16:00:09 -0400
In-Reply-To: <1ba2fa240807160549u68d9ecby25e79d832d772a0a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tomas Winkler" <tomasw@gmail.com>
Date: Wed, 16 Jul 2008 15:49:34 +0300

> On Tue, Jul 15, 2008 at 6:45 AM, David Miller <davem@davemloft.net> wrote:
> > From: "John W. Linville" <linville@tuxdriver.com>
> > Date: Mon, 14 Jul 2008 15:23:02 -0400
> >
> > drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 6 has type 's64'
> > drivers/net/wireless/iwlwifi/iwl-led.c:271: warning: format '%lld' expects type 'long long int', but argument 7 has type 'u64'
> 
> I cannot reproduce this. Wasn't this conversion already solved or
> still need to cast to long long int?

You have to cast u64/s64 values to long long if you want to print them
using %llX specifiers, because some 64-bit platforms define these
types as plain "long".
