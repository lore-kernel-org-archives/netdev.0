From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] vxlan: combine VXLAN_FLOWBASED into
 VXLAN_COLLECT_METADATA
Date: Wed, 5 Aug 2015 09:19:05 -0700
Message-ID: <55C23779.9020601@plumgrid.com>
References: <1438753867-32403-1-git-send-email-ast@plumgrid.com>
 <20150805144242.GB3530@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34485 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbbHEQTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 12:19:06 -0400
Received: by pawu10 with SMTP id u10so39497284paw.1
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 09:19:06 -0700 (PDT)
In-Reply-To: <20150805144242.GB3530@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/5/15 7:42 AM, Thomas Graf wrote:
> I have no objection since a flag to enable tx only can be added again if
> needed. As stated in the other thread, the tx only mode which is what
> VXLAN was capable of doing so far is what motivated the split of flags.

I see the intent. A bit confusing though, since today FLOWBASED
affects pieces of TX and RX and COLLECT_METADATA another piece of RX.
After the patch COLLECT_METADATA does it all. imo cleaner.
but yeah, as you said, we can add 'tx only' later if really needed.
thanks for review!
