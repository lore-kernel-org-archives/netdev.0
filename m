From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/19] netfilter: IPv6 NAT
Date: Fri, 10 Aug 2012 00:30:15 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208100025500.26308@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <20120809220014.GB26051@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120809220014.GB26051@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Aug 2012, Pablo Neira Ayuso wrote:

> Hi Patrick,
>
> On Thu, Aug 09, 2012 at 10:08:44PM +0200, kaber@trash.net wrote:
>> The following patches contain an updated version of IPv6 NAT against
>> Linus' current tree.
>>
>> The series is organized as follows:
>>
>> - Patches 01-03 contain bugfixes for SIP helper bugs/regressions
>>   present in the current kernel
>
> Thanks, I'll pass these to David.
>
> I have also two more to fixes to oopses regarding SIP. I'm expecting
> one user to finally confirm that their issues are fixed.

If you want me to have a look as well, just send me an URL or the patches.

>> - Patches 04-06 improve conntrack fragmentation handling, the IPv6
>>   parts are also a precondition for IPv6 NAT
>>
>> - Patches 07 and 08 prepare the current NAT code for conversion to
>>   an address family independant core, but contain no functional
>>   changes
>>
>> - Patch 09 adds the address family independant NAT core and converts
>>   the existing IPv4-only NAT code to an AF-specific module
>>
>> - Patches 10 and 11 add some infrastructure for IPv6 NAT
>>
>> - Patch 12 adds IPv6 NAT support
>>
>> - Patches 13-15 add IPv6 specific NAT targets
>>
>> - Patches 16-19 add some IPv6-capable ports of existing NAT helpers
>>
>> - Patch 19 is independant of the IPv6 NAT code and adds support for
>>   stateless IPv6 prefix translation, just to relieve my conscience ;)
>>
>>
>> Since the last posting numerous bugs have been fixed, I don't remember
>> all of them, the more important ones include:
>>
>> - automatic NAT module loading in ctnetlink
>>
>> - address selection when mapping to IPv6 ranges
>>
>> - handling of IPv6 fragments
>>
>> - NAT handling of ICMPv6 error messages
>
> Thanks, I was keeping the previous patchset in one branch:
>
> http://1984.lsi.us.es/git/nf-next/log/?h=nf-nat4
>
> You can also find forward ports of netlink-mmap (from Florian Westpal)
> and one for nftables from myself in that tree.

Thanks, Florian just pointed me to these trees. Will have a look at
the changes compared to my tree. I'm actually intending to finish up
the mmaped netlink work once I'm done with IPv6 NAT.

>> Besides implementing IPv6 NAT, there are no known bugs left. Userspace
>> patches will follow shortly.
>
> We have this branch for iptables IPv6 NAT:
>
> http://git.netfilter.org/cgi-bin/gitweb.cgi?p=iptables.git;a=shortlog;h=refs/heads/nf-nat
>
> Let me know if you're OK with these.

For now I'll just accumulate feedback and will incorporate it into my 
tree. I'll also diff them against your tree and will then send the
final result once all feedback/fixes are included.

