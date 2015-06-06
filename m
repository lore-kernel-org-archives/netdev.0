From: Toan Pham <tpham3783@gmail.com>
Subject: Re: kmalloc panic
Date: Sat, 6 Jun 2015 19:10:19 -0400
Message-ID: <CAGNmLEP0o9bnGEh-P=AVxUp-_rh9pO-zOiwUq_HboptRQ60dTA@mail.gmail.com>
References: <5565CAA1.9070409@redpinesignals.com>
	<CAM_iQpUGLW44vzkN-5TJ9ww3RSz=2sRMnm7GKP6V0N9WGszRZQ@mail.gmail.com>
	<1432803793.2459.2.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	pavani <pavani.muthyala@redpinesignals.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:33877 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbbFFXKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 19:10:20 -0400
In-Reply-To: <1432803793.2459.2.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am experiencing a similar issue on another system (at91sam9n12) that
uses Redpine Signal Wireless Driver 1.1.0.  I do not know the root
cause yet,  but it may be related to the Redpine Signals driver.  Will
update this mailing list if the problem is with the redpine driver.
thanks

On Thu, May 28, 2015 at 5:03 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Wed, 2015-05-27 at 22:15 -0700, Cong Wang wrote:
>
>> > rsi_client: module license 'Proprietary' taints kernel.
>> > Disabling lock debugging due to kernel taint
>> > RSI_Init called and registering the client driver
>
> If this is what I think it is - the redpine signals wifi driver, then I
> have no interest in this bug report whatsoever.
>
> Please tell us
>  * the exact kernel version, best with local patches
>  * the wifi driver used
>
>> > INFO: Allocated in 0x10100100 age=2669517238 cpu=16842820 pid=335563024
>
> and what function this really was (0x10100100 isn't really useful).
>
> johannes
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
