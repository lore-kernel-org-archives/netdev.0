From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Mon, 12 Mar 2012 15:17:36 +0530
Message-ID: <CAOD=uF4CisG9QeVoVjcrBHWfrXk4i6aBhYQxwNL=uUVa978RMw@mail.gmail.com>
References: <CAOD=uF4Vx581zvpAT0dHKjUkrdsiZo-DTNR352V8tALM_P2roA@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6E99@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6E99@saturn3.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

here "mac" is in "u64" and I have casted it to "__le64".
Because its required there.

If you have any better suggestion, please let me know.


regards
santosh

On Mon, Mar 12, 2012 at 3:07 PM, David Laight <David.Laight@aculab.com>=
 wrote:
>
>
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org
>> [mailto:netdev-owner@vger.kernel.org] On Behalf Of santosh
>> prasad nayak
>> Sent: 11 March 2012 09:17
>> To: Rajesh Borundia
>> Cc: Sony Chacko; netdev; linux-kernel; kernel-janitors@vger.kernel.o=
rg
>> Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
>>
>> Thanks Rajesh for clarification.
>> Included all your inputs in the following patch.
>> This is for review not a formal one. Once review is done I will send=
 a
>> formal patch.
>
> I'm not sure of the exact nature of the issues here,
> but whenever I see code that casts between the addresses
> of integer types large bells start ringing - such code
> tends to have unwanted dependencies against the sizes
> and endiannesses of the relevant fields.
> This code might be ok, but lines like:
>> + =A0 =A0 if (*(__le64 *)mac =3D=3D cpu_to_le64(~0ULL)) {
> rather give me the willies.
>
> =A0 =A0 =A0 =A0David
>
>
