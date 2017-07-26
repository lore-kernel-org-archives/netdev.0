From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH iproute2] bridge: Assume master at FDB modification
Date: Wed, 26 Jul 2017 19:21:49 +0300
Message-ID: <b8516b28-bdab-9b6a-539a-d069d100b579@mellanox.com>
References: <1501083394-26180-1-git-send-email-arkadis@mellanox.com>
 <20170726090820.0252da7e@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        nikolay@cumulusnetworks.com, vivien.didelot@savoirfairelinux.com,
        mlxsw@mellanox.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0065.outbound.protection.outlook.com ([104.47.0.65]:49096
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750893AbdGZQV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:21:56 -0400
In-Reply-To: <20170726090820.0252da7e@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/26/2017 07:08 PM, Stephen Hemminger wrote:
> On Wed, 26 Jul 2017 18:36:34 +0300
> Arkadi Sharshevsky <arkadis@mellanox.com> wrote:
> 
>> According to the man page the master flag should be the default, yet, the
>> current code assumes otherwise.
>>
>> Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
> 
> Agree that the documentation and code don't match.
> But your change could break users with existing scripts by changing behavior.
> 
> It would be safer to change the man page not the code.
> 

Can we maybe set master and self by default. It doesn't make
sense by default to not include the bridge, it will not cause
regression in this case.
