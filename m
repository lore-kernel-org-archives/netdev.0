From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: Use netdev_<level>, dev_<level>,
	pr_<level>
Date: Thu, 3 Jun 2010 20:15:17 -0700
Message-ID: <AANLkTikEUsaB4cbs4DwfpdeuaPNDUa1tA-ANP0FdZY3L@mail.gmail.com>
References: <20100604025225.16120.30293.stgit@localhost.localdomain>
	<20100603.200443.104041687.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com,
	emil.s.tantilov@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57559 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757007Ab0FDDPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:15:18 -0400
Received: by iwn37 with SMTP id 37so559487iwn.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 20:15:17 -0700 (PDT)
In-Reply-To: <20100603.200443.104041687.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 3, 2010 at 20:04, David Miller <davem@davemloft.net> wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Thu, 03 Jun 2010 19:53:41 -0700
>
>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>
>> This patch is alternative to a previous patch submitted by Joe Perch=
es.
>>
>> Create common macros e_<level> and e_dev_<level> that use netdev_<le=
vel> and
>> dev_<level> similar to e1000e.
>> Redefined pr_fmt for driver messages.
>> Use %pM to display MAC address.
>> Aligned text to better match the new format.
>>
>> CC: Joe Perches <joe@perches.com>
>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>
> Applied, but:
>
>> =C2=A0/**
>> - * ixgbe_get_hw_dev_name - return device name string
>> + * ixgbe_get_hw_dev return device
>> =C2=A0 * used by hardware layer to print debugging information
>> =C2=A0 **/
>
> This line had trailing whitespace, which GIT warns about and I
> had to remove.
> --

Sorry about that Dave, not sure why I did not catch that.  Thanks
