From: Roi Dayan <roid@mellanox.com>
Subject: Re: [net] vxlan: fix use-after-free on deletion
Date: Thu, 1 Jun 2017 14:32:49 +0300
Message-ID: <c1f40352-0d67-f14c-2b52-69c908f992de@mellanox.com>
References: <1496306615-770-1-git-send-email-markb@mellanox.com>
 <20170601105308.0be70eb4@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roid@mellanox.com>, <roopa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>
To: Jiri Benc <jbenc@redhat.com>, Mark Bloch <markb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0064.outbound.protection.outlook.com ([104.47.1.64]:58577
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750952AbdFALc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 07:32:58 -0400
In-Reply-To: <20170601105308.0be70eb4@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/06/2017 11:53, Jiri Benc wrote:
> On Thu, 1 Jun 2017 11:43:35 +0300, Mark Bloch wrote:
>> Adding a vxlan interface to a socket isn't symmetrical, while adding
>> is done in vxlan_open() the deletion is done in vxlan_dellink().
>> This can cause a use-after-free error when we close the vxlan
>> interface before deleting it.
>>
>> We add vxlan_vs_del_dev() to match vxlan_vs_add_dev() and call
>> it from vxlan_stop() to match the call from vxlan_open().
>>
>> Signed-off-by: Mark Bloch <markb@mellanox.com>
>
> Acked-by: Jiri Benc <jbenc@redhat.com>
>

Hi, I did some tests and didn't reproduce the original kasan issue
reported.

Tested-by: Roi Dayan <roid@mellanox.com>
