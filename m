From: dag dg <dagofthedofg@gmail.com>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: add device IDs for Dell 5804 (Novatel
 E371) WWAN card
Date: Wed, 8 May 2013 14:11:48 -0500
Message-ID: <CAO2Qn5myQRhscszx0WRX588EP5NzPZuOsr1mrH3p4yDna8YP-w@mail.gmail.com>
References: <1367874878.31762.0.camel@dcbw.foobar.com> <1367875057.31762.3.camel@dcbw.foobar.com>
 <87li7r6bx1.fsf@nemi.mork.no> <20130508.120850.755474428060131481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	Dan Williams <dcbw@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130508.120850.755474428060131481.davem@davemloft.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just a side note on this. By default for this device, modprobe won't
load and assign the option driver. However, if cdc_ether is
blacklisted and you try to load option onto the device, it will try to
load the option driver onto where cdc_ether was being used, which will
cause the system to lock up. I'm not sure what needs to be done to
force qmi_wwan to take over cdc_ether without option grabbing these
IDs...

On Wed, May 8, 2013 at 2:08 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Bj=F8rn Mork <bjorn@mork.no>
> Date: Mon, 06 May 2013 23:22:50 +0200
>
>> Dan Williams <dcbw@redhat.com> writes:
>>
>>> A rebranded Novatel E371 for AT&T's LTE bands.  qmi_wwan should dri=
ve this
>>> device, while cdc_ether should ignore it.  Even though the USB desc=
riptors
>>> are plain CDC-ETHER that USB interface is a QMI interface.
>>>
>>> Cc: <stable@vger.kernel.org>
>>> Signed-off-by: Dan Williams <dcbw@redhat.com>
>>> ---
>>>  drivers/net/usb/cdc_ether.c | 7 +++++++
>>>  drivers/net/usb/qmi_wwan.c  | 7 +++++++
>>>  2 files changed, 14 insertions(+)
>>
>> Acked-by: Bj=F8rn Mork <bjorn@mork.no>
>
> Applied.
