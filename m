From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-02-20
Date: Tue, 21 Feb 2012 15:40:53 -0500 (EST)
Message-ID: <20120221.154053.2103818562080068513.davem@davemloft.net>
References: <20120221151435.GA19354@tuxdriver.com>
	<20120221.144417.1445117001833888214.davem@davemloft.net>
	<CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andrei.emeltchenko.news@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMXE1-qB8_5oGey2=Ypa5BitZnye3YqdM=yB8oKCGLvoZu_8HQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Andrei Emeltchenko <andrei.emeltchenko.news@gmail.com>
Date: Tue, 21 Feb 2012 22:38:16 +0200

> Hi David,
>=20
> On Tue, Feb 21, 2012 at 9:44 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: "John W. Linville" <linville@tuxdriver.com>
>> Date: Tue, 21 Feb 2012 10:14:36 -0500
>>
>>> On Mon, Feb 20, 2012 at 07:23:24PM -0500, David Miller wrote:
>>>> From: "John W. Linville" <linville@tuxdriver.com>
>>>> Date: Mon, 20 Feb 2012 15:37:40 -0500
>>>>
>>>> > Here is another batch of fixes intended for 3.3. =A0Most of the =
fixes
>>>> > this time are for Bluetooth.
>>>>
>>>> Pulled, but please read the bluetooth changes more carefully in th=
e
>>>> future, there were a lot of coding style errors introduced this
>>>> time around.
>>>
>>> I pinged Johan about this, and he tells me that he spoke to Marcel
>>> as well. =A0They were a bit unsure about the issue. =A0Is your conc=
ern
>>> primarily about some excessive tabbing for indentation of parameter=
s
>>> and such?
>>
>> So you actually looked at the changes you pushed to me and you are
>> telling me you personally can't find anything that looks like garbag=
e?
>>
>> Really? =A0Do I really have to point out such obvious stuff like thi=
s?
>> Are you serious?
>>
>> Look at ca0d6c7ece0e78268cd7c5c378d6b1b610625085 ("Bluetooth: Add
>> missing QUIRK_NO_RESET test to hci_dev_do_close")
>>
>> You tell me what the heck you think of this thing.
>>
>> - =A0 =A0 =A0 if (!test_bit(HCI_RAW, &hdev->flags)) {
>> + =A0 =A0 =A0 if (!test_bit(HCI_RAW, &hdev->flags) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 test_b=
it(HCI_QUIRK_NO_RESET, &hdev->quirks)) {
>>
>> That's disgusting, it jumps off the screen and says "Hello, I am ugl=
y
>> as sin". =A0How in the world can you miss something like this? =A0Fo=
ur
>> TABs on the second line? =A0Why? =A0I can't believe we even have to =
discuss
>> something like this, seriously.
>=20
> Sorry did we understand wrong text of Linux coding style? Or do we ne=
ed
> right interpretation of it?

I'm not engaging in this conversation any more, I don't care what Codin=
gStyle
says, the quoted code is garbage.
