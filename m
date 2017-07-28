From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rt2x00: make const array glrt_table static
Date: Fri, 28 Jul 2017 19:51:11 +0300
Message-ID: <877eyswlmo.fsf@purkki.adurom.net>
References: <20170711114733.15387-1-colin.king@canonical.com>
        <20170728150130.336D06095E@smtp.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        linux-wireless@vger.kernel.org, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170728150130.336D06095E@smtp.codeaurora.org> (Kalle Valo's
        message of "Fri, 28 Jul 2017 15:01:30 +0000 (UTC)")
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kalle Valo <kvalo@codeaurora.org> writes:

> Colin Ian King <colin.king@canonical.com> wrote:
>
>> From: Colin Ian King <colin.king@canonical.com>
>> 
>> Don't populate array glrt_table on the stack but make it static.
>> Makes the object code a smaller by over 670 bytes:
>> 
>> Before:
>>    text	   data	    bss	    dec	    hex	filename
>>  131772	   4733	      0	 136505	  21539	rt2800lib.o
>> 
>> After:
>>    text	   data	    bss	    dec	    hex	filename
>>  131043	   4789	      0	 135832	  21298	rt2800lib.o
>> 
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>> Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
>
> Patch applied to wireless-drivers-next.git, thanks.
>
> 17830147c40a mwifiex: fix spelling mistake: "Insuffient" -> "Insufficient"

Dave had applied this earlier and my script failed to detect that. Hence
the commit above is wrong.

commit bf98bd0be1ba509c5e6d77524ffac192f1edb2dd
Author:     Colin Ian King <colin.king@canonical.com>
AuthorDate: Tue Jul 11 12:47:33 2017 +0100
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Thu Jul 13 09:23:56 2017 -0700

    rt2x00: make const array glrt_table static

-- 
Kalle Valo
