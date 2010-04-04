From: Alexandre Cassen <acassen@freebox.fr>
Subject: Bug#575970: iproute2: silence errors about kernel missing 6rd on "ip tun show".
Date: Sun, 4 Apr 2010 22:23:43 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1004042217520.24519@lnxos.staff.proxad.net>
References: <20100331080854.GA3810@amd64.fatal.se> <20100331160642.75766629@s6510>
Reply-To: Alexandre Cassen <acassen@freebox.fr>, 575970@bugs.debian.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andreas Henriksson <andreas@fatal.se>, 575970@bugs.debian.org,
    netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.575970.B575970.127041263715568@bugs.debian.org>
In-Reply-To: <20100331160642.75766629@s6510>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Hello,

On Wed, 31 Mar 2010, Stephen Hemminger wrote:
> On Wed, 31 Mar 2010 10:08:54 +0200
> Andreas Henriksson <andreas@fatal.se> wrote:
>
>> Hello!
>>
>> As reported in http://bugs.debian.org/575970 there is currently a warning
>> printed for every tunnel when using latest iproute2 on atleast <= 2.6.32
>> kernels (missing 6rd?!).
>>
>> The attached patch avoids perror when errno is EINVAL, which I assume
>> is the way to detect missing 6rd support. A better/cleaner
>> method to detect and avoid 6rd when there's no kernel support
>> is more then welcome.
>>
>> Regards,
>> Andreas Henriksson
>>
>
> I will wait (a little while) to see if Alexandre has a preferred alternative.


IMHO, the proper way to detect 6rd kernel missing support is to catch 
EINVAL, but not others errno since they might be usefull in some case.

Reading the code again, there is also a need to test tunnel protocol since 
6rd scope is ipv6/ip only.

I will send another email with a proposed patch to fix those 2 issues.

Regs,
Alexandre
