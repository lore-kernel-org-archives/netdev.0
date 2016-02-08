From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Mon, 8 Feb 2016 12:22:36 -0500
Message-ID: <CA+A7VXWLjAffBMYXLXZafayz6N-w8BHhrPg_f-oSLX+Bv_Ss6Q@mail.gmail.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
 <1454946096-9752-9-git-send-email-jprvita@endlessm.com> <F8D31DB3-94AF-47CC-8091-7B6478983B53@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux@endlessm.com,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <F8D31DB3-94AF-47CC-8091-7B6478983B53@holtmann.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Marcel,

On 8 February 2016 at 11:20, Marcel Holtmann <marcel@holtmann.org> wrot=
e:
> Hi Joa Paulo,
>
>> Provide an interface for the airplane-mode indicator be controlled f=
rom
>> userspace. User has to first acquire the control through
>> RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole t=
ime
>> it wants to be in control of the indicator. Closing the fd or using
>> RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.
>>
>> To change state of the indicator, the RFKILL_OP_AIRPLANE_MODE_CHANGE
>> operation is used, passing the value on "struct rfkill_event.soft". =
If
>> the caller has not acquired the airplane-mode control beforehand, th=
e
>> operation fails.
>
> as explained in an earlier response, the concept Airplane Mode seems =
to be imposing policy into the kernel. Do we really want have this as a=
 kernel exposed API.
>

On that very same thread we decided to keep using the "airplane mode"
name both for when having the default policy of "set it when all
radios are off" or when allowing userspace to override the default.
Please see the following message from Johannes
http://www.spinics.net/lists/linux-wireless/msg146069.html and let me
know if that covers your concern.

Thanks!

--
Jo=C3=A3o Paulo Rechi Vita
http://about.me/jprvita
