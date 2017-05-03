From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Wed, 3 May 2017 21:02:20 +0200
Message-ID: <936bf348-58ac-882c-a433-83f209862deb@broadcom.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
 <20161226163559.GB27087@amd> <20170103175924.GC13946@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Ming Lei <ming.lei@canonical.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36112 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751209AbdECTCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 15:02:25 -0400
Received: by mail-wm0-f45.google.com with SMTP id u65so156369417wmu.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 12:02:24 -0700 (PDT)
In-Reply-To: <20170103175924.GC13946@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3-1-2017 18:59, Luis R. Rodriguez wrote:
> On Mon, Dec 26, 2016 at 05:35:59PM +0100, Pavel Machek wrote:
>>
>> Right question is "should we solve it without user-space help"?
>>
>> Answer is no, too. Way too complex. Yes, it would be nice if hardware
>> was designed in such a way that getting calibration data from kernel
>> is easy, and if you design hardware, please design it like that. But
>> N900 is not designed like that and getting the calibration through
>> userspace looks like only reasonable solution.
> 
> Arend seems to have a better alternative in mind possible for other
> devices which *can* probably pull of doing this easily and nicely,
> given the nasty history of the usermode helper crap we should not
> in any way discourage such efforts.
> 
> Arend -- please look at the firmware cache, it not a hash but a hash
> table for an O(1) lookups would be a welcomed change, then it could
> be repurposed for what you describe, I think the only difference is
> you'd perhaps want a custom driver hook to fetch the calibration data
> so the driver does whatever it needs.

Hi Luis,

I let my idea catch dust on the shelf for a while. Actually had a couple
of patches ready, but did get around testing them. So I wanted to rebase
them on your linux-next tree. I bumped into the umh lock thing and was
wondering why direct filesystem access was under that lock as well. In
your tree I noticed a fix for that. The more reason to base my work on
top of your firmware_class changes. Now my question is what is the best
branch to choose, because you have a "few" in that repo to choose from ;-)

Regards,
Arend
