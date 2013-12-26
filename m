From: Arend van Spriel <arend@broadcom.com>
Subject: Re: 3.13-rc4: lockdep warning in network stack
Date: Thu, 26 Dec 2013 16:54:34 +0100
Message-ID: <52BC513A.3010501@broadcom.com>
References: <52B9794C.8040506@broadcom.com> <CADVnQykeb8CUXxSxm5OYS2vz1XvMWz3=GObLw1ACb_P_XZ_tQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:59493 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab3LZPyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 10:54:37 -0500
In-Reply-To: <CADVnQykeb8CUXxSxm5OYS2vz1XvMWz3=GObLw1ACb_P_XZ_tQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/2013 06:55 PM, Neal Cardwell wrote:
> On Tue, Dec 24, 2013 at 7:08 AM, Arend van Spriel <arend@broadcom.com> wrote:
>> Hi David,
>>
>> Noticed this lockdep warning. As rc4 is already out for a while it may
>> already be known. It happened upon initial login, but that may have been
>> a coincidence. Attached are the dmesg output and the kernel configuration.
> 
> Yes, this should be fixed in Linux 3.13-rc5 with:
> 
>   e47eb5d udp: ipv4: do not use sk_dst_lock from softirq context

Thanks, Neal

That looks promising. Will move to rc5 then.

Regards,
Arend
