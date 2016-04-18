From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2] carl9170: Clarify kconfig text
Date: Mon, 18 Apr 2016 19:42:05 +0300
Message-ID: <87r3e2kgwy.fsf@kamboji.qca.qualcomm.com>
References: <20160416113312.8de2266358165182bb4b4a15@gmx.com>
	<20160416171856.1769c0e16bcc75372407e06f@gmx.com>
	<87shyiyl8a.fsf@purkki.adurom.net> <3244016.0TmHG3E4A9@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauri Kasanen <cand@gmx.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sgruszka@redhat.com, emmanuel.grumbach@intel.com,
	linuxwifi@intel.com, johannes.berg@intel.com,
	emmanuel.grumbach@intel.com
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3244016.0TmHG3E4A9@debian64> (Christian Lamparter's message of
	"Mon, 18 Apr 2016 18:20:06 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christian Lamparter <chunkeey@googlemail.com> writes:

> On Monday, April 18, 2016 06:45:09 PM Kalle Valo wrote:
>> Lauri Kasanen <cand@gmx.com> writes:
>> 
>> > --- a/drivers/net/wireless/ath/carl9170/Kconfig
>> > +++ b/drivers/net/wireless/ath/carl9170/Kconfig
>> > @@ -5,12 +5,10 @@ config CARL9170
>> >  	select FW_LOADER
>> >  	select CRC32
>> >  	help
>> > -	  This is another driver for the Atheros "otus" 802.11n USB devices.
>> > +	  This is the mainline driver for the Atheros "otus" 802.11n USB devices.
>> >  
>> > -	  This driver provides more features than the original,
>> > -	  but it needs a special firmware (carl9170-1.fw) to do that.
>> > -
>> > -	  The firmware can be downloaded from our wiki here:
>> > +	  It needs a special firmware (carl9170-1.fw), which can be downloaded
>> > +	  from our wiki here:
>> >  	  <http://wireless.kernel.org/en/users/Drivers/carl9170>
>> 
>> Why even mention anything about a "special firmware" as the firmware is
>> already available from linux-firmware.git? 
>
> Yes and no. 1.9.6 is in linux-firmware.git. I've tried to add 1.9.9 too
> but that failed.
> <http://comments.gmane.org/gmane.linux.kernel.wireless.general/114639>

Rick's comment makes sense to me, better just to provide the latest
version. No need to unnecessary confuse the users. And if someone really
wants to use an older version that she can retrieve it from the git
history.

>> That's default location for all firmware images and I think most, if not all,
>> distros should have it available. So wouldn't it be better not to mention 
>> anything about firmware at all?
>
> Sure, but this could be a different patch then. I think Intel devices 
> (iwlwifi, iwlegacy and ipw2x00) have a similar text about "download
> firmware from this device from our homepage here" too. So if we want,
> we can remove them altogether?

So iwlwifi now has:

	  In order to use this driver, you will need a firmware
	  image for it. You can obtain the microcode from:

	          <http://wireless.kernel.org/en/users/Drivers/iwlwifi>.

Maybe that could be changed to mention about the wiki page in general:

	  The driver has a wiki page at:

	          <http://wireless.kernel.org/en/users/Drivers/iwlwifi>.

But I know iwlwifi updates the firmware images pretty often so Emmanuel
might see this differently.

-- 
Kalle Valo
