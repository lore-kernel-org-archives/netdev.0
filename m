From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for loading NVS calibration data
Date: Fri, 27 Jan 2017 17:23:07 +0200
Message-ID: <87bmus5xyc.fsf@kamboji.qca.qualcomm.com>
References: <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
        <87tw8lnei3.fsf@codeaurora.org> <20170127094342.GC24223@pali>
        <def4c357-64c0-0681-a5d5-f49a6cb84a92@broadcom.com>
        <20170127101043.GD24223@pali>
        <f60cf2c0-bc1e-3a5f-991c-dc6c95a656af@broadcom.com>
        <20170127103408.GG24223@pali>
        <87bmus7mfk.fsf@kamboji.qca.qualcomm.com>
        <20170127115706.GH24223@pali>
        <8737g47kpd.fsf@kamboji.qca.qualcomm.com>
        <20170127131146.GI24223@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Ming Lei <ming.lei@canonical.com>,
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
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127131146.GI24223@pali> ("Pali \=\?utf-8\?Q\?Roh\=C3\=A1r\=22'\?\=
 \=\?utf-8\?Q\?s\?\= message of "Fri, 27
        Jan 2017 14:11:46 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> On Friday 27 January 2017 14:26:22 Kalle Valo wrote:
>> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
>>=20
>> > 2) It was already tested that example NVS data can be used for N900 e.=
g.
>> > for SSH connection. If real correct data are not available it is better
>> > to use at least those example (and probably log warning message) so us=
er
>> > can connect via SSH and start investigating where is problem.
>>=20
>> I disagree. Allowing default calibration data to be used can be
>> unnoticed by user and left her wondering why wifi works so badly.
>
> So there are only two options:
>
> 1) Disallow it and so these users will have non-working wifi.
>
> 2) Allow those data to be used as fallback mechanism.
>
> And personally I'm against 1) because it will break wifi support for
> *all* Nokia N900 devices right now.

All two of them? :)

But not working is exactly my point, if correct calibration data is not
available wifi should not work. And it's not only about functionality
problems, there's also the regulatory aspect.

>> > 3) If we do rename *now* we will totally break wifi support on Nokia
>> > N900.
>>=20
>> Then the distro should fix that when updating the linux-firmware
>> packages. Can you provide details about the setup, what distro etc?
>
> Debian stable, Ubuntu LTSs 14.04, 16.04.=20

You can run these out of box on N900?

> And I think that other LTS distributions contains that example nvs
> file too (I'm not going to verify others, but list will be probably
> long). Upgrading linux-firmware is against policy of those
> distributions. So no this is not an solution.

So instead we should workaround distro policies in kernel? Come on.

Seriously, just rename the file in linux-firmware and file a bug (with a
patch) to distros. If they don't fix the bug you just have to do a
custom hack for N900. But such is life.

--=20
Kalle Valo
