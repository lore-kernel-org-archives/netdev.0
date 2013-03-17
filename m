From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: ethernet: ti: davinci_emac: fix
 usage of cpdma_check_free_tx_desc()
Date: Sun, 17 Mar 2013 12:19:21 -0400 (EDT)
Message-ID: <20130317.121921.1333305173173774055.davem@davemloft.net>
References: <1363356616-32480-1-git-send-email-mugunthanvnm@ti.com>
	<CA+V-a8sM9q6eVqu8nMf1S1jhZEf3zJsPYr_8_waRinfeX17t5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: prabhakar.csengg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756252Ab3CQQTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:19:25 -0400
In-Reply-To: <CA+V-a8sM9q6eVqu8nMf1S1jhZEf3zJsPYr_8_waRinfeX17t5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prabhakar Lad <prabhakar.csengg@gmail.com>
Date: Sat, 16 Mar 2013 12:43:14 +0530

> Hi Mugunthan
> 
> Thanks for the patch!
> 
> On Fri, Mar 15, 2013 at 7:40 PM, Mugunthan V N <mugunthanvnm@ti.com> wrote:
>> Fix which was done in the following commit in cpsw driver has
>> to be taken forward to davinci emac driver as well.
>>
>> commit d35162f89b8f00537d7b240b76d2d0e8b8d29aa0
>> Author: Daniel Mack <zonque@gmail.com>
>> Date:   Tue Mar 12 06:31:19 2013 +0000
>>
>>     net: ethernet: cpsw: fix usage of cpdma_check_free_tx_desc()
>>
>>     Commit fae50823d0 ("net: ethernet: davinci_cpdma: Add boundary for rx
>>     and tx descriptors") introduced a function to check the current
>>     allocation state of tx packets. The return value is taken into account
>>     to stop the netqork queue on the adapter in case there are no free
>>     slots.
>>
>>     However, cpdma_check_free_tx_desc() returns 'true' if there is room in
>>     the bitmap, not 'false', so the usage of the function is wrong.
>>
>> Reported-by: Prabhakar Lad <prabhakar.csengg@gmail.com>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> 
>  Tested-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied, thanks.
