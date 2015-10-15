From: Arun Parameswaran <aparames@broadcom.com>
Subject: Re: [PATCH 1/1] net: phy: bcm-phy-lib: Fix module license issue
Date: Thu, 15 Oct 2015 10:11:07 -0700
Message-ID: <561FDE2B.7090205@broadcom.com>
References: <1444768812-31476-1-git-send-email-arunp@broadcom.com>
 <1444768812-31476-2-git-send-email-arunp@broadcom.com>
 <20151014.183947.1675991536904094202.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bcm-kernel-feedback-list <bcm-kernel-feedback-list@broadcom.com>
To: David Miller <davem@davemloft.net>,
	Arun Parameswaran <arunp@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:47453 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591AbbJORLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 13:11:12 -0400
In-Reply-To: <20151014.183947.1675991536904094202.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 15-10-14 06:39 PM, David Miller wrote:
> From: Arun Parameswaran <arunp@broadcom.com>
> Date: Tue, 13 Oct 2015 13:40:12 -0700
>
>> The 'bcm-phy-lib.c', added as a part of the commit
>> "net: phy: Add Broadcom phy library for common interfaces"
>> was missing the module license. This was causing an issue
>> when the library is built as a module; "module license
>> 'unspecified' taints kernel".
>>
>> This patch fixes the issue by adding the module license,
>> author and description to the bcm-phy-lib.c file.
>>
>> Fixes: a1cba5613edf5 ("net: phy: Add Broadcom phy library for common
>> interfaces")
>> Signed-off-by: Arun Parameswaran <arunp@broadcom.com>
> This patch doesn't apply to my net-next tree at all.

There is a mismatch in the 'git diff' output, for the last 3 lines in
bcm-phy-lib.c

For some reason the patch I created has '@@ -207,3 +208,6 @@', instead of
'@@ -206,3 +207,7 @@', when created from the 'net-next'.

I will send out a patch based on the 'net-next'.

Thanks
Arun
