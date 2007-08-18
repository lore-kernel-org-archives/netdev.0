From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 8/9] define global BIT macro
Date: Sat, 18 Aug 2007 19:13:47 +0200
Message-ID: <46C728CB.6060102@gmail.com>
References: <737828602404912540@wsc.cz>	<428714662539710215@wsc.cz> <20070818094602.0ea69c27.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
 linux-kernel@vger.kernel.org,  source@mvista.com,
 dougthompson@xmission.com,  bluesmoke-devel@lists.sourceforge.net,
 dtor@mail.ru,  linux-input@atrey.karlin.mff.cuni.cz,
 netdev@vger.kernel.org,  James.Bottomley@SteelEye.com,
 linux-scsi@vger.kernel.org,  gtolstolytkin@ru.mvista.com,
 vitalywool@gmail.com,  dsaxena@plexity.net,  ralf@linux-mips.org,
 linux-mips@linux-mips.org,  mchehab@infradead.org,
 video4linux-list@redhat.com,  jbenc@suse.cz,  flamingice@sourmilk.net,
 linux-wireless@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20070818094602.0ea69c27.randy.dunlap@oracle.com>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Randy Dunlap napsal(a):
> On Sat, 18 Aug 2007 11:44:12 +0200 (CEST) Jiri Slaby wrote:
> 
>> define global BIT macro
>>
>> move all local BIT defines to the new globally define macro.
>>
>> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
>>
>> ---
>>
>>  include/linux/bitops.h                      |    1 +
>>  include/video/sstfb.h                       |    1 -
>>  include/video/tdfx.h                        |    2 --
>>  net/mac80211/ieee80211_i.h                  |    2 --
>>  18 files changed, 1 insertions(+), 37 deletions(-)
>>
>> diff --git a/include/linux/bitops.h b/include/linux/bitops.h
>> index 3255b06..a57b81f 100644
>> --- a/include/linux/bitops.h
>> +++ b/include/linux/bitops.h
>> @@ -3,6 +3,7 @@
>>  #include <asm/types.h>
>>  
>>  #ifdef	__KERNEL__
>> +#define BIT(nr)			(1UL << (nr))
>>  #define BIT_MASK(nr)		(1UL << ((nr) % BITS_PER_LONG))
>>  #define BIT_WORD(nr)		((nr) / BITS_PER_LONG)
>>  #define BITS_TO_TYPE(nr, t)	(((nr)+(t)-1)/(t))
> 
> 
> So users of the BIT() macro in include/linux/input.h can be
> changed to use the global BIT_MASK() macro...
> and the former can be removed.

I'm afraid I don't understand you. Maybe, you are writing about changes done in
patch no. 7 [1], which didn't go through to the lkml?

[1]
http://www.fi.muni.cz/~xslaby/sklad/07-get-rid-of-input-bit-duplicate-defines.patch

thanks,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
