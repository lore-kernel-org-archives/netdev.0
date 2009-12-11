From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: mmotm-2009-12-08-17-45 resume slowly
Date: Fri, 11 Dec 2009 17:10:56 +0800
Message-ID: <a8e1da0912110110m425d8544xdcdf1f5a9ed8ab17@mail.gmail.com>
References: <a8e1da0912100127k4dcddd65gfe5ff0b1330fe63b@mail.gmail.com>
	 <a8e1da0912100130i2e654796mf899dd27df869673@mail.gmail.com>
	 <20091210184931.257A.A69D9226@jp.fujitsu.com>
	 <4B217219.6040109@crca.org.au>
	 <a8e1da0912101747l7e0e9fcbh8a7007e95e7c8509@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Nigel Cunningham <ncunningham-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a8e1da0912101747l7e0e9fcbh8a7007e95e7c8509-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 11, 2009 at 9:47 AM, Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=
 wrote:
> On Fri, Dec 11, 2009 at 6:11 AM, Nigel Cunningham
> <ncunningham-VWkGxi2CTS+6c6uEtOJ/EA@public.gmane.org> wrote:
>> Dave, could you be more specific?
>>
>> Is the delay Ksaki has picked out related to your report...
>
> I can not reproduce the wireless delay today, maybe related to
> wireless environment?
>
>>
>> KOSAKI Motohiro wrote:
>>> (cc to netdev)
>>>
>>> Hi net-folks
>>>
>>>>> [ =C2=A0561.323866] mtrr: type mismatch for e0000000,10000000 old=
:
>>>>> write-back new: write-combining
>>>>> [ 2688.500033] No probe response from AP 00:02:2d:08:51:2b after
>>>>> 500ms, disconnecting.
>>>>> [ 2689.580376] wlan0: direct probe to AP 00:02:2d:08:51:2b (try 1=
)
>>>
>>> What's mean "No probe response"? Why its point waste 2000sec?

Rereading the dmesg I post, I think maybe this delay is not relevant
because it is after "PM: Finishing wakeup."

The brightness is so low after resume finished that I thought it as
resume delay.


>>
>> [...]
>>
>>>>> [ =C2=A0225.731462] ACPI: Preparing to enter system sleep state S=
3
>>>>> [ =C2=A0225.754167] Disabling non-boot CPUs ...
>>>>> [ =C2=A0225.809478] CPU 1 is now offline
>>>>> [ =C2=A0225.809481] lockdep: fixing up alternatives.
>>>>> [ =C2=A0225.809487] SMP alternatives: switching to UP code
>>>>> [ =C2=A0225.816500] Extended CMOS year: 2000
>>>>> [ =C2=A0225.816500] Back to C!
>>>>> [ =C2=A0225.816500] Extended CMOS year: 2000
>>>>> [ =C2=A0225.816720] Enabling non-boot CPUs ...
>>>>> [ =C2=A0225.818422] lockdep: fixing up alternatives.
>>>>> [ =C2=A0225.818425] SMP alternatives: switching to SMP code
>>>>> [ =C2=A0225.822188] Booting processor 1 APIC 0x1 ip 0x6000
>>>>> [ =C2=A0225.818021] Initializing CPU#1
>>>>> [ =C2=A0225.818021] CPU: Physical Processor ID: 0
>>>>> [ =C2=A0225.818021] CPU: Processor Core ID: 1
>>>>> [ =C2=A0225.913392] CPU1: Intel(R) Core(TM)2 Duo CPU =C2=A0 =C2=A0=
 T7250 =C2=A0@ 2.00GHz stepping 0d
>>>>> [ =C2=A0225.937046] microcode: CPU1 sig=3D0x6fd, pf=3D0x80, revis=
ion=3D0xa3
>>>>> [ =C2=A0225.937053] platform microcode: firmware: requesting inte=
l-ucode/06-0f-0d
>>>>> [ =C2=A0225.937179] firmware microcode: parent microcode should n=
ot be sleeping
>>>>> [ =C2=A0285.940840] CPU1 is up
>>
>> ... or the 60 second delay before the CPU1 is up message?
>
> Yes, this delay occurs every time


Then what caused this one, any idea?

>
>>
>> Regards,
>>
>> Nigel
>>
>
>
>
> --
> Regards
> dave
>



--=20
Regards
dave
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
