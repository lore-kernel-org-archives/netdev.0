From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] wireless: iwlegacy:  make const array static to shink object code size Content-Type: text/plain; charset="utf-8" Content-Transfer-Encoding: 8bit
Date: Fri, 22 Sep 2017 13:32:35 +0300
Message-ID: <87efqz81mk.fsf@kamboji.qca.qualcomm.com>
References: <20170921225630.21916-1-colin.king@canonical.com>
        <20170922095609.GA27551@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Colin King <colin.king@canonical.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922095609.GA27551@redhat.com> (Stanislaw Gruszka's message
        of "Fri, 22 Sep 2017 11:56:10 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanislaw Gruszka <sgruszka@redhat.com> writes:

> On Thu, Sep 21, 2017 at 11:56:30PM +0100, Colin King wrote:
>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> Don't populate const array ac_to_fifo on the stack in an inlined
>> function, instead make it static.  Makes the object code smaller
>> by over 800 bytes:
>> 
>>    text	   data	    bss	    dec	    hex	filename
>>  159029	  33154	   1216	 193399	  2f377	4965-mac.o
>> 
>>    text	   data	    bss	    dec	    hex	filename
>>  158122	  33250	   1216	 192588	  2f04c	4965-mac.o
>> 
>> (gcc version 7.2.0 x86_64)
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>
> Content type information was added at the end of the topic, but
> I think Kalle can fix that when he will be committing the patch.

Yeah, I'll fix that when I commit this. But very good that you pointed
it out, I might miss stuff like this.

I'll also remove the "wireless:" prefix from the title.

-- 
Kalle Valo
