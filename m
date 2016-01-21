From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH] net: wireless: rt2x00: Fixed Spacing issues
Date: Thu, 21 Jan 2016 18:02:45 +0100
Message-ID: <CAGXE3d-3M6s0k0rbA2-vihLfwvjhdVgxDsQSt_84WxXme+U7bg@mail.gmail.com>
References: <1445112279-27796-1-git-send-email-paulmcquad@gmail.com>
	<CAGXE3d-nbDGOgxGiasPixtiUhNtWZ+C7AgV3zMQAo1JN9KgbNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stanislaw Gruszka <sgruszka@redhat.com>, kvalo@codeaurora.org,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Paul McQuade <paulmcquad@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXE3d-nbDGOgxGiasPixtiUhNtWZ+C7AgV3zMQAo1JN9KgbNw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 21, 2016 at 5:56 PM, Helmut Schaa
<helmut.schaa@googlemail.com> wrote:
> On Sat, Oct 17, 2015 at 10:04 PM, Paul McQuade <paulmcquad@gmail.com> wrote:
>> Removed empty spaces before/after parenthesis
>>
>> Signed-off-by: Paul McQuade <paulmcquad@gmail.com>
>
> Just noticed these did not get applied by Kalle yet.

Kalle, can you fix up the path (ralink/rt2x00 instead of rt2x00) when applying?
Or would you prefer Paul to respin the whole code style cleanup series?

Thanks,
Helmut

> Looks good to me.
>
> Acked-by: Helmut Schaa <helmut.schaa@googlemail.com>
>
>> ---
>>  drivers/net/wireless/rt2x00/rt61pci.h | 20 ++++++++++----------
>>  1 file changed, 10 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/wireless/rt2x00/rt61pci.h b/drivers/net/wireless/rt2x00/rt61pci.h
>> index 1442075..ab86415 100644
>> --- a/drivers/net/wireless/rt2x00/rt61pci.h
>> +++ b/drivers/net/wireless/rt2x00/rt61pci.h
>> @@ -138,14 +138,14 @@
>>  #define PAIRWISE_TA_TABLE_BASE         0x1a00
>>
>>  #define SHARED_KEY_ENTRY(__idx) \
>> -       ( SHARED_KEY_TABLE_BASE + \
>> -               ((__idx) * sizeof(struct hw_key_entry)) )
>> +       (SHARED_KEY_TABLE_BASE + \
>> +               ((__idx) * sizeof(struct hw_key_entry)))
>>  #define PAIRWISE_KEY_ENTRY(__idx) \
>> -       ( PAIRWISE_KEY_TABLE_BASE + \
>> -               ((__idx) * sizeof(struct hw_key_entry)) )
>> +       (PAIRWISE_KEY_TABLE_BASE + \
>> +               ((__idx) * sizeof(struct hw_key_entry)))
>>  #define PAIRWISE_TA_ENTRY(__idx) \
>> -       ( PAIRWISE_TA_TABLE_BASE + \
>> -               ((__idx) * sizeof(struct hw_pairwise_ta_entry)) )
>> +       (PAIRWISE_TA_TABLE_BASE + \
>> +               ((__idx) * sizeof(struct hw_pairwise_ta_entry)))
>>
>>  struct hw_key_entry {
>>         u8 key[16];
>> @@ -180,7 +180,7 @@ struct hw_pairwise_ta_entry {
>>  #define HW_BEACON_BASE3                        0x2f00
>>
>>  #define HW_BEACON_OFFSET(__index) \
>> -       ( HW_BEACON_BASE0 + (__index * 0x0100) )
>> +       (HW_BEACON_BASE0 + (__index * 0x0100))
>>
>>  /*
>>   * HOST-MCU shared memory.
>> @@ -1287,9 +1287,9 @@ struct hw_pairwise_ta_entry {
>>  /*
>>   * DMA descriptor defines.
>>   */
>> -#define TXD_DESC_SIZE                  ( 16 * sizeof(__le32) )
>> -#define TXINFO_SIZE                    ( 6 * sizeof(__le32) )
>> -#define RXD_DESC_SIZE                  ( 16 * sizeof(__le32) )
>> +#define TXD_DESC_SIZE                  (16 * sizeof(__le32))
>> +#define TXINFO_SIZE                    (6 * sizeof(__le32))
>> +#define RXD_DESC_SIZE                  (16 * sizeof(__le32))
>>
>>  /*
>>   * TX descriptor format for TX, PRIO and Beacon Ring.
>> --
>> 2.6.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
