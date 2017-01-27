From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Fri, 27 Jan 2017 13:53:28 +0100
Message-ID: <bc26f6a5-2865-356f-7f19-f3a316257759@broadcom.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <87tw8lnei3.fsf@codeaurora.org> <20170127094342.GC24223@pali>
 <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
 <20170127101043.GD24223@pali>
 <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
 <20170127103408.GG24223@pali> <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
 <20170127115706.GH24223@pali> <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 27-1-2017 13:26, Kalle Valo wrote:
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
>> On Friday 27 January 2017 13:49:03 Kalle Valo wrote:
>>> Pali Rohár <pali.rohar@gmail.com> writes:
>>>
>>>>> So
>>>>> for those other platforms there will be a delay waiting for user-mode
>>>>> helper to fail, before trying to get nvs file from /lib/firmware.
>>>>
>>>> Yes, there will be. But there is no easy way to fix this problem that
>>>> kernel is trying to use default/example NVS data...
>>>
>>> Kernel is doing correctly and requesting NVS data as expected, the
>>> problem here is that linux-firmware claims that the example NVS data is
>>> real calibration data (which it is not). Distros should not use that,
>>> only developers for testing purposes. We should not courage users using
>>> example calibration data.
>>>
>>> The simple fix is to rename the NVS file in linux-firmware to something
>>> like wl1251-nvs.bin.example, no need to workaround this in kernel. If
>>> you send a patch to linux-firmware I'm happy to ack that.
>>
>> I agree with rename and fact that default/example data should not be
>> used.
>>
>> But...
>>
>> 1) Kernel should not read device/model specific data from VFS where
>> are stored not-device-specific files preinstalled by linux
>> distributions.
>>
>> And linux distributions are already putting files into VFS and kernel
>> cannot enforce userspace to not do that (as they are already doing it).
> 
> I'm having problems to understand what you are saying here.

This is a personal opinion. I read it as: /lib/firmware can only contain
files for from linux-firmware.

At least the device-specific vs. non-device-specific does not seem to
hold. The firmware files that we have in the linux-firmware repository
are very device-specific. Unless you mean the 'platform' when talking
about 'device'.

Regards,
Arend
