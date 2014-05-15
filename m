From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH] net: tunnels - enable module autoloading
Date: Thu, 15 May 2014 23:42:58 +0200
Message-ID: <CAG-2HqWeJKbipVm+1oxKQYQfFyqu4SdSH15BP-4OAaUbJBCVdg@mail.gmail.com>
References: <1399970908-9973-1-git-send-email-teg@jklm.no> <20140515143202.53ca8033@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>, yoshfuji@linux-ipv6.org,
	jmorris@namei.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140515143202.53ca8033@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2014 at 11:32 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Tue, 13 May 2014 10:48:28 +0200
> Tom Gundersen <teg@jklm.no> wrote:
>
>> Enable the module alias hookup to allow tunnel modules to be autoloaded on demand.
>>
>> This is in line with how most other netdev kinds work, and will allow userspace
>> to create tunnels without having CAP_SYS_MODULE.
>>
>> Signed-off-by: Tom Gundersen <teg@jklm.no>
>> Tested-by: Susant Sahani <susant@redhat.com>
>> ---
>>  net/ipv4/ipip.c       | 1 +
>>  net/ipv6/ip6_tunnel.c | 1 +
>>  net/ipv6/sit.c        | 1 +
>>  3 files changed, 3 insertions(+)
>
> But tunnel modules are autoloaded now.
> If I create a tunnel with ip tunnel based on the existing MODULE_ALIAS_NETDEV().

Hm, please correct me if I'm wrong, but this only works if you create
a tunnel with one of the hardcoded tunnel names, right? And also, if I
read the code correctly, it only works if you use the ioctl interface
and not the rtnl interface?

What we'd like to do is to use the rtnl interface to create tunnels
with arbitrary names, is there a way this can already be done that I
have missed?

Cheers,

Tom
