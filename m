From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] ethtool: RXHASH flag support
Date: Tue, 30 Mar 2010 13:37:13 -0400
Message-ID: <4BB236C9.7080300@garzik.org>
References: <20100328154448.701c89ee@nehalam>	<20100329174727.4654e19c@nehalam>	<20100329175352.38008e05@nehalam>	<4BB234DD.9040800@garzik.org> <20100330103207.7fc5681a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:40250 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab0C3RhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 13:37:17 -0400
Received: by pva18 with SMTP id 18so2915750pva.19
        for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 10:37:15 -0700 (PDT)
In-Reply-To: <20100330103207.7fc5681a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/30/2010 01:32 PM, Stephen Hemminger wrote:
> On Tue, 30 Mar 2010 13:29:01 -0400
> Jeff Garzik<jeff@garzik.org>  wrote:
>
>> By blindly sync'ing the ethtool.h header, ETHTOOL_MAX_NTUPLE_LIST_ENTRY
>> and its sibling ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY were removed,
>> breaking the ethtool build.
>
> In the patch I moved it to ethtool.c to have local entries.
>
> I believe that all cloned headers should only come from the result
> of kernel "make install_headers".  Not locally different vrsions.

There is nothing locally different about ethtool-copy.h.

	Jeff




