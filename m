From: P@draigBrady.com
Subject: Re: 2.6.7 tulip performance (with NAPI)
Date: Fri, 08 Oct 2004 10:25:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41665CF9.3060001@draigBrady.com>
References: <41633174.7070805@candelatech.com> <16740.17875.574967.11417@robur.slu.se> <41646587.7070401@candelatech.com> <41649425.1010102@candelatech.com> <16741.45331.743721.822091@robur.slu.se> <20041007234413.GC24969@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Ben Greear <greearb@candelatech.com>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041007234413.GC24969@xi.wantstofly.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> On Thu, Oct 07, 2004 at 11:11:47PM +0200, Robert Olsson wrote:
>=20
>=20
>> I'm interested if anyone has done any pktgen performance tests with
>> w. S2IO or other 10G card we need to upgrade the lab equipment.=20
>> Both 64 byte pkts and MTU sized pkts is interesting.  Anyone?
>=20
>=20
> If you're interested in raw pps numbers and willing to use something
> other than pktgen to attain them, you might want to look into the intel
> IXP-based boards.  You actually have to write some microcode and upload
> it to an on-chip processor array, but you can easily sustain wirespeed
> at 4Gbps (IXP2400-based) or 10Gbps (IXP2800-based.)

Good suggestion. This is exactly what I'm doing on a (2400 based)
radisys enp-2611 board. Faced with the cost of a smartbits it's
a no brainer for me. I haven't written the =B5 code yet btw.

P=E1draig.
