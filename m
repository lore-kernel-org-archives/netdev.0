From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Tue, 16 Jun 2015 19:35:38 +0200
Message-ID: <55805E6A.90805@hartkopp.net>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de>	<557DCD0A.5040500@hartkopp.net>	<557DD20E.4080005@hartkopp.net>	<557E7D89.30301@6wind.com>	<557E9728.7080208@6wind.com> <20150615085410.6628b5bb@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.161]:31581 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbbFPRfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 13:35:53 -0400
In-Reply-To: <20150615085410.6628b5bb@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.06.2015 17:54, Stephen Hemminger wrote:
> On Mon, 15 Jun 2015 11:13:12 +0200
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Theoretically, virtual interfaces should advertise an IFLA_LINK to 0.
>> I don't know what is the best fix:
>>    - patching iproute2 to avoid this '@NONE'
>>    - patching the kernel (see below).
>
>
> Sorry this is an ABI change. The kernel has to go back
> to doing the same thing as before.
>

Isn't this too late right now at 4.1-rc8 stage???

At least the patch suggested for br_device.c at

http://marc.info/?l=linux-netdev&m=143435960111768&w=2

would been necessary in all networking drivers, right?

I currently see this @NONE stuff with virtual CAN devices too.

Regards,
Oliver

ps. will apply the patch from Nicolas if it fixes the ip output.
