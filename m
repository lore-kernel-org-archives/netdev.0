From: Antti Palosaari <crope@iki.fi>
Subject: Re: 3.9 merge window kernels
Date: Tue, 26 Feb 2013 09:51:42 +0200
Message-ID: <512C698E.7070306@iki.fi>
References: <20130222234825.GB2419@hansolo.jdub.homelinux.org> <20130222210938.4f62cede@redhat.com> <512816AD.9050406@gmail.com> <20130222223014.1b9a2cc0@redhat.com> <512857FB.3050803@gmail.com> <20130223090148.4a4bd5e0@redhat.com> <CA+5PVA46LfV-WTkJVF7fz9nrz1Qrib894fqMo+8GL8AjuW8_Yg@mail.gmail.com> <5129491A.5020406@gmail.com> <512AAED8.3070205@iki.fi> <512BFC31.7010800@gmail.com> <20130226011209.GC2071@hansolo.jdub.homelinux.org> <512C1B5C.20604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@redhat.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	kernel@lists.fedoraproject.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Stephen Hemminger <shemminger@osdl.org>
To: poma <pomidorabelisima@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:47648 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab3BZHwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 02:52:47 -0500
In-Reply-To: <512C1B5C.20604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2013 04:18 AM, poma wrote:
> On 02/26/13 02:12, Josh Boyer wrote:
>> On Tue, Feb 26, 2013 at 01:05:05AM +0100, poma wrote:
>>> On 02/25/13 01:22, Antti Palosaari wrote:
>>> [=E2=80=A6]
>>>>>> Poma, you should probably just start filing bugs for things you =
hit.
>>>>>> In this case, the skge backtrace is just a warning but it can be=
 fixed
>>>>>> up relatively easily.
>>>>>>
>>>>>
>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D914994
>>>>> Josh, Mauro thanks for the overview. :)
>>>>> Antti, cheers. ;)
>>>>>
>>>>> poma
>>>>
>>>> I cannot see these warnings at all. What is Kernel option to enabl=
e
>>>> those debug(?) warnings? From which menu it could be located when =
make
>>>> menuconfig ?
>>>>
>>>
>>> http://kojipkgs.fedoraproject.org/packages/kernel/3.9.0/0.rc0.git7.=
1.fc19/data/logs/x86_64/build.log
>>> Even after reapplying Stephen's "skge: check for PCI dma mapping
>>> errors"[1] from David's 'net-next' tree, no luck.
>>> =E2=80=A6
>>> WARNING: at lib/dma-debug.c:933 check_unmap+0x47b/0x960()
>>> skge 0000:01:09.0: DMA-API: device driver failed to check map
>>> error[device address=3D0x000000010287094a] [size=3D90 bytes] [mappe=
d as single]
>>> =E2=80=A6
>>
>> I'm confused.  You pointed to the build I did this morning, which
>> definitely doesn't include the commit you mentioned.  Are you saying=
 you
>> took this morning's build and applied the patch yourself?  If so, di=
d it
>> really get applied?  Do you have logs?  Do you have more than just t=
hat
>> tiny snippet of error message?
>>
>
> build.log is for Antti's eyes only. :)
> Logs are virtually the same, with or without that *old* commit, which=
 is
> actually replaced by this one[1].
> So of course it isn't in 3.9.0-0.rc0.git7.1.fc19.x86_64. ;)
> Building particular module groups(skge & Co.) rather than build an
> entire kernel tree isn't big deal, likewise.
> You know that better than me. ;)
> The real question is whether someone will help squeeze this bug.

I want just know if I could reproduce that AF9015 error message or was=20
it just warning. Is it something I have to fix for Kernel 3.10 or=20
earlier. I am running Fedora 17 AMD64 and could surely compile any=20
Kernel needed.

regards
Antti

--=20
http://palosaari.fi/
