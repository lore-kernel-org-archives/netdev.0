From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] net: Add phys_port identifier to struct net_device
 and export it to sysfs
Date: Fri, 28 Jun 2013 09:33:45 -0700
Message-ID: <51CDBAE9.1020807@gmail.com>
References: <20130617181004.GA1364@fedora-17-guest.dell.com>  <51BF59D8.10806@gmail.com>  <E31FB011129F30488D5861F383904915210BB90367@BLRX7MCDC201.AMER.DELL.COM>  <1371656194.1956.25.camel@bwh-desktop.uk.level5networks.com>  <E31FB011129F30488D5861F383904915210BB9042A@BLRX7MCDC201.AMER.DELL.COM> <1371670481.1956.105.camel@bwh-desktop.uk.level5networks.com> <51C4892B.8000806@gmail.com> <E31FB011129F30488D5861F383904915210BC0481A@BLRX7MCDC201.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	john.r.fastabend@intel.com
To: Narendra_K@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f170.google.com ([209.85.160.170]:59421 "EHLO
	mail-gh0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845Ab3F1QeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 12:34:03 -0400
Received: by mail-gh0-f170.google.com with SMTP id z10so908214ghb.29
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 09:34:02 -0700 (PDT)
In-Reply-To: <E31FB011129F30488D5861F383904915210BC0481A@BLRX7MCDC201.AMER.DELL.COM>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>> Also, do you think this will be primarily useful for partitioning devices that
>> expose multiple physical functions? Or do you see a use case for SR-IOV with
>> virtual functions as well. The pyhs_port attribute provides a common
>> interface for both cases which is good I suppose in the VF case however the
>> host can already learn this. I gather from your original post here that you are
>> aware of all this.
>>
>
> John, I think it will be useful in the SRIOV scenario also when more
than one VF from two NICs are assigned to the guest. phys_port would be
helpful in choosing the correct slave interfaces when host details are
not available.

OK. But I'm not sure why you would assign two VFs from the same NIC
to a guest? This doesn't seem like a good configuration for failover
because if one VF fails it seems likely both will fail. Maybe there
are some benefits for load balancing? Or my assumption both VFs will
fail is wrong.

Anyways it does seem useful in the partitioning case with multiple
physical functions.

.John

-- 
John Fastabend         Intel Corporation
