From: Manish Chopra <manish.chopra@qlogic.com>
Subject: RE: [PATCH net] bnx2x: Configure device endianity on driver load
 and reset endianity on removal.
Date: Mon, 1 Sep 2014 15:33:20 +0000
Message-ID: <31AFFC7280259C4184970ABA9AFE8B93E0800207@avmb3.qlogic.org>
References: <1409581043-25357-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1634 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753702AbaIAPdX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 11:33:23 -0400
In-Reply-To: <1409581043-25357-1-git-send-email-manish.chopra@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Manish Chopra
> Sent: Monday, September 01, 2014 7:47 PM
> To: David Miller
> Cc: netdev; Ariel Elior; Yuval Mintz
> Subject: [PATCH net] bnx2x: Configure device endianity on driver load and reset
> endianity on removal.
> 
> Some hosts can be both little and big endian.
> In certain scenarios a big endian kernel can kexec a little endian kernel.
> 
> This patch fixes this case from both ends:
> 1) Return endianity to original values on shutdown (in case little endian kernel
> boots after we shutdown).
> 2) Do not rely on HW reset values when loading driver in little endian kernel
>    but configure them explicitly (in case previous kernel was big endian and did
> not reset the HW).
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
> ---
> 
> Hi David,
> 
> Please consider applying this patch to `net'
> 
> Thanks,
> Manish

David, Please drop this patch as it might create issue for VFs.
I will send updated V2 patch with proper fix. 

Thanks,
Manish 
 
