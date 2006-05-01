From: Alexander Kulakov <a.kulakov@mail.ru>
Subject: Re: [Bugme-new] [Bug 6468] New: sky2 driver doesnt work in 2.6.16-r3,
 -r4 but was working in 2.6.15-r8
Date: Mon, 01 May 2006 00:32:49 -0400
Message-ID: <44558F71.8080000@mail.ru>
References: <200605010011.k410BCd1023886@fire-2.osdl.org> <20060430181543.6e38a842.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [69.57.231.22] ([69.57.231.22]:37003 "EHLO
	mail.biggiesports.co.uk") by vger.kernel.org with ESMTP
	id S1750789AbWEAEdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 00:33:42 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060430181543.6e38a842.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> (Please resond via reply-to-all, not via the bugzilla UI)
>
> bugme-daemon@bugzilla.kernel.org wrote:
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=6468
>>
>>            Summary: sky2 driver doesnt work in 2.6.16-r3,-r4 but was working
>>                     in 2.6.15-r8
>>     Kernel Version: 2.6.16-r4
>>             Status: NEW
>>           Severity: high
>>              Owner: jgarzik@pobox.com
>>          Submitter: a.kulakov@mail.ru
>>
>>
>> Most recent kernel where this bug did not occur:
>> 2.6.15-r8
>>
>> Distribution:
>> gentoo
>>
>> Hardware Environment:
>> Asus A38, Pentium-M 2.0GHz, 1024M RAM, Marvell Technology Group Ltd. 88E8053
>> PCI-E Gigabit Ethernet Controller (rev 19)
>>
>> Problem Description:
>> No packets are received by programs while ifconfig counts them. No iptables
>> rules in effect and all chans policies set to ACCEPT.
>> dhcpcd fails to get response from server. tcpdump doesnt show any incoming
>> packets while shows outgoing. ifconfig indicates that both rx and tx get increased!
>>
>> That driver was working for me till 2.6.15-r8. It doesn't work with 2.6.16-r3
>> nor -r4. I didn't try earlier 2.6.16 kernels but will do that if needed.
>>
>> I tried to load module with disable_msi=1 but it didn't make any difference.
>>
>> Steps to reproduce:
>> modprobe sky2 debug=16
>> dhcpcd eth0
>> tcpdump -n -i eth0
>>
>>     
>
> I assume that when you say "2.6.16-r4" you actually mean "2.6.16-rc4"?  Or
> do you mean 2.6.16.4?  It matters rather a lot.
>
> So, please confirm the earliest known-to-be-broken kernel version and the
> latest known-to-be-working version, using the correct release
> identification, thanks.
>
>
>   
My apologies. That was false alert. It seems to be Gentoo kernel patches
problem.
I just finished checking kernels from kernel.org and found 2.6.16,
2.6.16.6 and 2.6.16.11 to be working well.


Sorry for wasting your time
