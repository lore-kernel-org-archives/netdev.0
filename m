From: Thibault Roulet <tr@omch.ch>
Subject: Bug#647513: TX watchdog fires for ipheth after phone upgraded to iOS 5
Date: Thu, 03 Nov 2011 16:09:31 +0100
Message-ID: <4EB2AEAB.6010603@omch.ch>
References: <20111103135222.3555.69704.reportbug@thib.infomaniak.ch> <1320331171.3079.31.camel@deadeye>
Reply-To: Thibault Roulet <tr@omch.ch>, 647513@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Diego Giagio <diego@giagio.com>, 647513@bugs.debian.org,
        netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.647513.B647513.132033297514785@bugs.debian.org>
In-Reply-To: <1320331171.3079.31.camel@deadeye>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org


On 11/03/2011 03:39 PM, Ben Hutchings wrote:
> On Thu, 2011-11-03 at 14:52 +0100, darx wrote:
>> Package: linux-2.6
>> Version: 3.0.0-3
>> Severity: important
>> Tags: upstream
>>
>> Hi,
>>
>> After IOS5 update on my iphone when I plug it on my Debian, it crashes.
>
> No it doesn't.

well, "crash" is a bit strong. It looks like a kernel hickups

>
>> As I'm using it as a modem it's quite problematic.
>>
>>
>> Nov  3 14:16:51 thib kernel: [  371.824017] ------------[ cut here
>> ]------------
>> Nov  3 14:16:51 thib kernel: [  371.824024] WARNING: at /build/buildd-
>> linux-2.6_3.0.0-3-amd64-9ClimQ/linux-2.6-3.0.0/debian/build/source_amd64_none/net/sched/sch_generic.c:255
>> dev_watchdog+0xe9/0x148()
>> Nov  3 14:16:51 thib kernel: [  371.824027] Hardware name: OptiPlex 780
>> Nov  3 14:16:51 thib kernel: [  371.824029] NETDEV WATCHDOG: eth1 (ipheth):
>> transmit queue 0 timed out
> [...]
>
> Diego, please can you investigate this.
>

Oh and I can add that I tested on this DELL Optiplex 780 machine and also a small HP mini 5101 laptop (same debian 
version). Same error.

Thanks

Thib
