From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx-softmac: fix warning from ignoring returned value
 from pci_enable_device
Date: Thu, 28 Sep 2006 08:47:16 -0500
Message-ID: <451BD264.3060708@lwfinger.net>
References: <451B595F.mailDJI11YVSN@lwfinger.net> <5640c7e00609280026m4c734f29i76a92860296d4b8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:63660 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1751892AbWI1Nr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 09:47:58 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
In-Reply-To: <5640c7e00609280026m4c734f29i76a92860296d4b8a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian McDonald wrote:
> On 9/28/06, Larry Finger <Larry.Finger@lwfinger.net> wrote:
>> Linus's tree now has a configuration option that prints a warning 
>> whenever
>> the returned value of any routine is ignored. This patch fixes the 
>> only such
>> warning for bcm43xx.
>>
> Can you tell me how to make this check please so I can check my code
> in the kernel? I could look it up but obviously you can tell me
> quickly :-)

It is the ENABLE_MUST_CHECK option that appeared with the 2.6.18-gitX updates in Linus's tree, where 
I think X was 4 or 6. When this was turned on, there were a LOT of new warnings.

Larry
