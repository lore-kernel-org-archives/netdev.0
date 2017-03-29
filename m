From: Gal Pressman <galp@mellanox.com>
Subject: Re: [PATCH ethtool] ethtool: Support for configurable RSS hash
 function
Date: Wed, 29 Mar 2017 14:56:38 +0300
Message-ID: <29780e3c-b8df-a4f7-72f5-53e94bd448b4@mellanox.com>
References: <1488981831-19376-1-git-send-email-galp@mellanox.com>
 <20170325145047.6a5a7967@cakuba.netronome.com>
 <20170327180203.GB29050@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eyal Perry <eyalpe@mellanox.com>
To: "John W. Linville" <linville@tuxdriver.com>,
        Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20065.outbound.protection.outlook.com ([40.107.2.65]:54656
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932074AbdC2L4y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 07:56:54 -0400
In-Reply-To: <20170327180203.GB29050@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/03/2017 21:02, John W. Linville wrote:
> On Sat, Mar 25, 2017 at 02:50:47PM -0700, Jakub Kicinski wrote:
>> On Wed,  8 Mar 2017 16:03:51 +0200, Gal Pressman wrote:
>>> This ethtool patch adds support to set and get the current RSS hash
>>> function for the device through the new hfunc mask field in the
>>> ethtool_rxfh struct. Kernel supported hash function names are queried
>>> with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
>>> mask according to its index in the string-set.
>>>
>>> Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
>>> Signed-off-by: Gal Pressman <galp@mellanox.com>
>>> Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
>> Hi John,
>>
>> It seems you have applied both my earlier patch with get support and
>> this:
>>
>> adbaa18b9bc1 ("ethtool: Support for configurable RSS hash function")
>> b932835d2302 ("ethtool: print hash function with ethtool -x|--show-rxfh-indir")
>>
>> Now we print the RSS function twice:
>>
>> RX flow hash indirection table for em4 with 4 RX ring(s):
>>     0:      [...]
>> RSS hash function: toeplitz  <--- from my adbaa18b9bc1
>> RSS hash key:
>> Operation not supported
>> RSS hash function:           <--- from this patch
>>     toeplitz: on
>>     xor: off
>>     crc32: off
>>
>> Reverting my patch is probably the easiest way forward, although I find
>> it more concise and easier to parse in test scripts :)
> Thanks for pointing-out this issue! I apologize for my own confusion.
>
> As you suggest, I will be reverting your patch.
>
> Thanks,
>
> John
126464e4da18 ('Revert "ethtool: Support for configurable RSS hash function"')

Seems like you ended up reverting my patch instead of Jakub's?
We lost the set hfunc functionality.
