From: sbs <gexlie@gmail.com>
Subject: Re: IGB driver upgrade
Date: Thu, 8 Jul 2010 16:45:09 +0400
Message-ID: <AANLkTimXkE12FH6D4XXZu6h8vxfaKp-wWVZTvydBx6WE@mail.gmail.com>
References: <AANLkTim6kfnr6yNeUXlLHOztB-qjyvj50D4p7nebqj9r@mail.gmail.com>
	<AANLkTinUoQG4BWC4Q2UFDwGvAwYujlUXz6P-ZLkZozaQ@mail.gmail.com>
	<4C293792.6070508@intel.com>
	<AANLkTim4zvNHegMqBnQG5jNGFU8nsaZbx83gv7FZuznu@mail.gmail.com>
	<4C2A1C3C.3040403@intel.com>
	<AANLkTim37IrxmK9EinvGDwx91D0V1P1Ll3jRhNVy-dtX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <AANLkTim37IrxmK9EinvGDwx91D0V1P1Ll3jRhNVy-dtX@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

i have tested next configurations for several days:

standalone 2.2.9 driver with 2.6.35-rc4 and RSS=3D0
standalone 2.2.9 driver with 2.6.33.2 and RSS=3D0
statically linked driver with 2.6.35-rc4 kernel

all three configurations had no any problems.
seems that IGB was fixed in 35-rc4.

gonna try 2.6.34.1 with static drivers tomorrow night.


On Mon, Jul 5, 2010 at 10:45 AM, sbs <gexlie@gmail.com> wrote:
> I have tested 2.0.6 and 2.1.9 modules for 4 days and there were no any
> issues detected :)
>
>
> On Tue, Jun 29, 2010 at 8:15 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>> sbs wrote:
>>>
>>> We're running 2.6.33.2 kernel version.
>>> I have compiled and installed 2.0.6 and 2.1.9 modules on two our server=
s.
>>>
>>> Strange freezes usually appears in several (1 or 2) days.
>>> So I'll let you know when it happen and what module version will be
>>> responsible for that
>>
>> Since the issue is being seen with the in-kernel driver and not the
>> standalone module one other possibility is that this could be an issue t=
hat
>> is specific to multi-queue. =A0You can test for this by setting the RSS
>> parameter to 0 for the standalone module to enable multiple queues on the
>> 2.2.9 driver.
>
> Thank you, I'll install 2.6.35-rc4 today on several servers with both
> standalone(with RSS=3D0) and static driver and let you know after.
>
>>
>> One other thing you might want to try would be to test the latest release
>> candidate kernel from kernel.org. =A0This would help to tell us if this =
is
>> still an issue in the current kernel, or an issue that is present in just
>> 2.6.33.
>>
>> Thanks,
>>
>> Alex
>>
>

---------------------------------------------------------------------------=
---
This SF.net email is sponsored by Sprint
What will you do first with EVO, the first 4G phone?
Visit sprint.com/first -- http://p.sf.net/sfu/sprint-com-first
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
