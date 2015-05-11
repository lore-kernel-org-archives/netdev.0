From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH linux v3 net-next 0/5] add netlink support for new lacp
 bonding parameters
Date: Mon, 11 May 2015 11:50:20 -0400
Message-ID: <5550CFBC.9050805@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com> <20150511.110004.649964826481502303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, shm@cumulusnetworks.com,
	razor@blackwall.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:33011 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753729AbbEKPuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:50:22 -0400
Received: by qcvo8 with SMTP id o8so47254614qcv.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 08:50:22 -0700 (PDT)
In-Reply-To: <20150511.110004.649964826481502303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 11:00 AM, David Miller wrote:
> From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
> Date: Sat,  9 May 2015 00:01:54 -0700
>
>> This is a resubmit of Mahesh's last 3 bonding patches from this series
>> (http://marc.info/?l=linux-netdev&m=142432864626179&w=2) with one
>> additional kernel patch which adds the netlink bits. I have noted any
>> modifications I did to the original patches just above my signoff line.
>> Patch 5 is the iproute2 support for these bonding options. All patches
>> were coded against the net-next branch of their respective projects.
>>
>> v2:
>>    * rebased
>>    * only send these new parameters via netlink when bond is in mode 4
>>    * fixed ad_actor_sys_prio to be 0xFFFF by default even when the bond
>>      is initially created in mode 0 and switched to mode 4
>>
>> v3:
>>    * reverted changes to bond_option_ad_actor_system_set() from v1 in Mahesh's
>>      patch "bonding: Allow userspace to set actors' macaddr in an AD-system."
>>      Instead implementing all setting in the option specific set function as
>>      Nik suggested.
>
> Series applied, thanks.
>
> There are actually 4 patches in this series, so this subject should have
> said "0/4" instead of "0/5" :-)
>

Thanks David, noted for next time, apologies for confusion.
