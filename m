From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] lib utils: fix family during af_bit_len
 calculation
Date: Wed, 25 Mar 2015 10:07:27 -0700
Message-ID: <1427303247.25985.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426645109-3411-1-git-send-email-roopa@cumulusnetworks.com>
	 <20150324150500.6159e407@urahara>
	 <1427290352.25985.111.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150325161349.GA21340@angus-think.wlc.globallogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35280 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbbCYRHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:07:32 -0400
Received: by pdbop1 with SMTP id op1so34343346pdb.2
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:07:31 -0700 (PDT)
In-Reply-To: <20150325161349.GA21340@angus-think.wlc.globallogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-25 at 18:13 +0200, Vadim Kochan wrote:

> I reproduced this once, but after not any more, I even tried to setup
> tcp servers with same address but with no luck, would you please dump
> stats into file by -D option and send it, in case if you will catch the
> issue ?

Yeah, this is strange, because after a small change, and a revert, I
could not reproduce it anymore.

Something fishy... maybe a Makefile bug ....
