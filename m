From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/4] forcedeth: fix MAC address detection on network card
 (regression in 2.6.23)
Date: Tue, 05 Feb 2008 14:13:28 -0500
Message-ID: <47A8B558.7060605@garzik.org>
References: <200802050746.m157ktY9010399@imap1.linux-foundation.org>	<47A8A90B.6010602@garzik.org> <20080205105909.fd8c6dbe.akpm@linux-foundation.org> <47A74C7E.8080101@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	michael.pyne@kdemail.net, LKML <linux-kernel@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760114AbYBETN7@vger.kernel.org>
In-Reply-To: <47A74C7E.8080101@nvidia.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> Andrew Morton wrote:
>> On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
>>
>>
>>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>>
>>> NAK - this fixes one set of users, and breaks a working set of users.
>>>
>>> Need to add DMI check for the specific motherboard 
>>> (dmi_check_system), and flip flag according to success/failure of 
>>> that check.
>>
>>
>> OK :)  I added the above to the changelog for next time.
>>
>> You guys can hide, but this patch isn't going away!
> 
> I believe Michael determined that a newer BIOS fixes this issue.


That's a solution that makes vendors happy... but we still have to deal 
with it in Linux.  There are plenty of the old broken BIOS still out in 
the field...

	Jeff
