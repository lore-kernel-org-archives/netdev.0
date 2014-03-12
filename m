From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/13] ixgbe: fix some multiline hw_dbg prints
Date: Wed, 12 Mar 2014 23:11:15 +0300
Message-ID: <5320BF63.30403@cogentembedded.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1394603618-1044-13-git-send-email-jeffrey.t.kirsher@intel.com>	 <53207459.5010306@cogentembedded.com> <1394649063.3030.3.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:62957 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaCLTLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 15:11:20 -0400
Received: by mail-lb0-f175.google.com with SMTP id w7so6975853lbi.34
        for <netdev@vger.kernel.org>; Wed, 12 Mar 2014 12:11:19 -0700 (PDT)
In-Reply-To: <1394649063.3030.3.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/12/2014 09:31 PM, Keller, Jacob E wrote:

>>> From: Jacob Keller <jacob.e.keller@intel.com>

>>> This patch fixes some formatting on multilined print messages, so that
>>> the text of the print appears on a single line, which aids in grepping
>>> the sourcecode for where the error came from.

>>> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
>>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> ---
>>>    drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 8 +++-----
>>>    1 file changed, 3 insertions(+), 5 deletions(-)

>>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>>> index 446df3c..3bc9b67 100644
>>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
>>> @@ -512,7 +512,7 @@ out:
>>>     *
>>>     * Disables link, should be called during D3 power down sequence.
>>>     *
>>> - */
>>> + **/

>>      Hm? What's this for?

> The extra **/ is part of the standard doc format for function headers,

    It is not. Reread Documentation/kernel-doc-nano-HOWTO.txt please.

WBR, Sergei
