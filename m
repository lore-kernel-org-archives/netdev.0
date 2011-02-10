From: "Leonardo  L. P. da Mata" <barroca@gmail.com>
Subject: Re: jme driver loses connection after resuming from suspend
Date: Thu, 10 Feb 2011 19:07:31 -0200
Message-ID: <AANLkTikV9Ncy3Jki1G20SrzA_HMiAk_hF3qY8U+vpZ1D@mail.gmail.com>
References: <AANLkTikrKEY7Zt5HvxQcJLk9eGne0BGD82NFEiWO4smt@mail.gmail.com>
	<20110128163315.1e4e8346.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Guo-Fu Tseng <cooldavid@cooldavid.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110128163315.1e4e8346.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Updated information on the bug, Guo-Fu Tseng says that might not be a
bug on the driver, but i've tested other network cards and they don't
share the same issue.

Also, on interesting update that people may consider is that after
running tcpdump on the device, the network starts working again.
Information are updated in the bug.

On Fri, Jan 28, 2011 at 10:33 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> (cc's added)
>
> On Fri, 28 Jan 2011 16:03:11 -0200
> "Leonardo =A0L. P. da Mata" <barroca@gmail.com> wrote:
>
>> Hello, i'm testing the kernel 2.6.37 on my hardware, Once connect on
>> wired network, i call the suspend with:
>> echo "mem" >/sys/power/state
>>
>> The system goes on suspend. After resuming from suspend, the network=
 card
>> cannot be used anymore.
>>
>>
>> The bug is reported here:
>> =A0https://bugzilla.kernel.org/show_bug.cgi?id=3D27692
>>
>> Can you please point me to similar problems on other network cards s=
o
>> i can get possible solutions on this.
>
>



--=20
Leonardo Luiz Padovani da Mata
barroca@gmail.com

"May the force be with you, always"
"Nerd Pride... eu tenho. Voce tem?"
