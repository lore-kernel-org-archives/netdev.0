From: Jes Sorensen <jes.sorensen@gmail.com>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Tue, 16 May 2017 09:44:19 -0400
Message-ID: <0ce21c48-1d2c-3035-3c6e-52c7debf86d5@gmail.com>
References: <20170515134711.2770374-1-arnd@arndb.de>
 <20170515142520.GA13996@redhat.com>
 <20170515.103951.2305484593464882104.davem@davemloft.net>
 <20170516115511.GA4230@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, arnd@arndb.de,
        helmut.schaa@googlemail.com, kvalo@codeaurora.org,
        daniel@makrotopia.org, dev@kresin.me, johannes.berg@intel.com,
        pozega.tomislav@gmail.com, vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170516115511.GA4230@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/16/2017 07:55 AM, Stanislaw Gruszka wrote:
> On Mon, May 15, 2017 at 10:39:51AM -0400, David Miller wrote:
>> Passing return values by reference is and always has been a really
>> poor way to achieve what these functions are doing.
>>
>> And frankly, whilst the tool could see what's going on here better, we
>> should be making code easier rather than more difficult to audit.
>>
>> I am therefore very much in favor of Arnd's change.
>>
>> This isn't even a situation where there are multiple return values,
>> such as needing to signal an error and return an unsigned value at the
>> same time.
>>
>> These functions return _one_ value, and therefore they should be
>> returned as a true return value.
> 
> In rt2x00 driver we use poor convention in other kind of registers
> accessors like bbp, mac, eeprom. I dislike to changing only rfcsr
> accessors and leaving others in the old way. And changing all accessors
> would be massive and error prone change, which I'm not prefer either.

That's why you do it in multiple smaller patches rather than one ugly 
giant patch.

The rt2x00 current register accessor functions makes the Realtek vendor 
driver equivalent ones look pretty, which is saying something.

Jes
