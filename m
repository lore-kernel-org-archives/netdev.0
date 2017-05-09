From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH net] rtnetlink: Fix the IFLA_PHYS_PORT_NAME TLV to include
 terminating NULL
Date: Tue, 9 May 2017 15:48:00 +0300
Message-ID: <108e1815-d80e-25a4-0d03-4ff9454a379c@mellanox.com>
References: <1494331922-16451-1-git-send-email-yotamg@mellanox.com>
 <20170509123107.GG10395@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <zhangshengju@cmss.chinamobile.com>,
        <roopa@cumulusnetworks.com>, <sd@queasysnail.net>,
        <bblanco@plumgrid.com>, <minipli@googlemail.com>,
        <nogahf@mellanox.com>, <moshe@mellanox.com>,
        <rshearma@brocade.com>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50088.outbound.protection.outlook.com ([40.107.5.88]:46004
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753218AbdEIMsL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 08:48:11 -0400
In-Reply-To: <20170509123107.GG10395@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/2017 03:31 PM, Tobias Klauser wrote:
> On 2017-05-09 at 14:12:02 +0200, Yotam Gigi <yotamg@mellanox.com> wrote:
>> The IFLA_PHYS_PORT_NAME rtnetlink TLV length does not include the
>> terminating NULL character, which is different from other string typed
>> TLVs. Due to the fact that libnl checks for the terminating NULL in every
>> string typed attribute, it crashes on every RTM_GETLINK response on
>> drivers that implement ndo_get_phys_port_name.
>>
>> Make the fill_phys_port_name function include the terminating NULL in the
>> TLV size by using the nla_put_string helper function.
>>
>> Fixes: db24a9044ee1 ("net: add support for phys_port_name")
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Cc: David Ahern <dsa@cumulusnetworks.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Acked-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>> Please consider this for stable too. Thanks!
> This is already fixed in commit 77ef033b687c ("rtnetlink: NUL-terminate
> IFLA_PHYS_PORT_NAME string").


You are right. I forgot to rebase my net tree :)
