From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 18 Jan 2017 14:53:52 +0100
Message-ID: <b12e913d-874b-734a-4401-88315b8459dc@neratec.com>
References: <1477305654-11328-1-git-send-email-zefir.kurtisi@neratec.com>
 <1477305654-11328-3-git-send-email-zefir.kurtisi@neratec.com>
 <e063a5fd-a1c5-e9ec-1700-21c6974a7cbe@codeaurora.org>
 <3291b7c1-7bf6-d776-adab-b89c9cd9be38@neratec.com>
 <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:46893 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751612AbdARNyB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 08:54:01 -0500
In-Reply-To: <5763c2fb-7286-15b0-091f-1abf26c0afe7@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 02:13 PM, Timur Tabi wrote:
> Zefir Kurtisi wrote:
>> The fact that you see the warning means external autoneg completes before the
>> SGMII side in best case or SGMII link remains down in worst case.
> 
> So I'm no expert on this.  Are you saying that I might possibly be doing things
> backwards in my driver?  That is, I should be configuring the SGMII side of the
> link before I start autonegotiation?
> 
No, not necessarily. The SGMII link default configuration is set such that you do
not have to bother at all.

That is, if in your case you see the warning popping up but the link always
regains connection, then it is an ignorable false positive.
