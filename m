From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Fri, 27 Jan 2017 11:30:47 +0200
Message-ID: <87poj87su0.fsf@kamboji.qca.qualcomm.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
        <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
        <87inp1ndgm.fsf@codeaurora.org> <20170127090538.GB24223@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
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
To: Pali =?utf-8?Q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127090538.GB24223@pali> ("Pali \=\?utf-8\?Q\?Roh\=C3\=A1r\=22'\?\=
 \=\?utf-8\?Q\?s\?\= message of "Fri, 27
        Jan 2017 10:05:38 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:

> On Friday 27 January 2017 09:56:09 Kalle Valo wrote:
>> Pali Roh=C3=A1r <pali.rohar@gmail.com> writes:
>>=20
>> > In case there is no valid MAC address kernel generates random one. This
>> > patch propagate this generated MAC address back to NVS data which will=
 be
>> > uploaded to wl1251 chip. So HW would have same MAC address as linux ke=
rnel
>> > uses.
>> >
>> > Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
>>=20
>> Why? What issue does this fix?
>
> Send permanent MAC address to wl1251 chip, same what is doing wl12xx
> driver.

Ok, so this doesn't change functionality in any way and you are adding
it only because wl12xx does the same? You should document that in the
the commit log.

If there's no change I don't really see the point of this. But if
there's harm, hopefully, I guess it's ok.

--=20
Kalle Valo
