From: walter harms <wharms@bfs.de>
Subject: Re: [patch net-next] net: qcom/emac: fix a sizeof() typo
Date: Mon, 13 Feb 2017 14:28:50 +0100
Message-ID: <58A1B492.9000103@bfs.de>
References: <20170213110021.GA17205@mwanda> <58A19E97.6000704@bfs.de> <23c98d90-913d-f590-2677-096bf5dc15ff@codeaurora.org>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02-sz.bfs.de ([194.94.69.103]:38358 "EHLO mx02-sz.bfs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752304AbdBMN2z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 08:28:55 -0500
In-Reply-To: <23c98d90-913d-f590-2677-096bf5dc15ff@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 13.02.2017 14:03, schrieb Timur Tabi:
> walter harms wrote:
>> We have a function where the argument is ignored and the rest is const ?
>>
>> emac_ethtool_get_regs_len seems the only user. So it would be fairly
>> easy to
>> move that into that function.
>>
>> @maintainer:
>> Is there a deeper logic behind this ?
> 
> I don't understand the question.


The question is: why is a simple calculation const*const
separated into a function ?

re,
 wh
