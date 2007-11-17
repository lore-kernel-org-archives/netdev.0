From: Andrew Morgan <morgan@kernel.org>
Subject: Re: 2.6.24-rc2-mm1 -- strange apparent network failures
Date: Fri, 16 Nov 2007 21:16:58 -0800
Message-ID: <473E794A.4060107@kernel.org>
References: <20071113175906.497a1a6a.akpm@linux-foundation.org>	<20071115100209.GB2513@shadowen.org>	<200711152028.29734.kjwinchester@gmail.com> <20071115164441.67a8e2df.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kamalesh@linux.vnet.ibm.com
To: Andrew Morton <akpm@linux-foundation.org>,
	Kevin Winchester <kjwinchester@gmail.com>, apw@shadowen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from twinlark.arctic.org ([207.29.250.54]:52087 "EHLO
	twinlark.arctic.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbXKQFRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 00:17:00 -0500
In-Reply-To: <20071115164441.67a8e2df.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

This warning is just saying that you might want to reconsider
recompiling your dhclient with a newer libcap - which has native support
for 64-bit capabilities. This is supposed to be informative, and not be
associated with any particular error.

- From your comments, you believe that this patch causes something in your
boot process to fail. Can you supply some detail about the version of
dhclient you are using? I'd like to understand exactly what it is doing
(via libcap).

Thanks

Andrew

Andrew Morton wrote:
> On Thu, 15 Nov 2007 20:28:29 -0400
> Kevin Winchester <kjwinchester@gmail.com> wrote:
> 
>> On November 15, 2007 06:02:09 am Andy Whitcroft wrote:
>>> When testing some of the later 2.6.24-rc2-mm1+hotfix combinations on three
>>> of our test systems one job from each batch (1/4) failed.  In each case the
>>> machine appears to have booted normally all the way to a login: prompt.
>>> However in the failed boots the networking though apparently initialised
>>> completely and correctly (as far as I can tell from the console output), is
>>> reported as not responding to ssh connections.  The network interface seems
>>> to have been initialised on the right port, and the ssh daemons started.
>>>
>>> Two of the machines are powerpc boxes, the other an older x86_64.
>>> One machine is 4/4 in testing, just one.  Most of the other machines are
>>> still not able to compile this stack so do not contribute to our knowledge.
>>>
>>> Any ideas?
>>>
>> I see this as well - the computer boots fine but no network.  The only clues 
>> in the dmesg are:
>>
>> [  294.097876] warning: process `dhclient' gets w/ old libcap
>> [  294.097893] warning: process `dhclient' sets w/ old libcap
>>
>> So I'll try backing up the patch series to before:
>>
>> add-64-bit-capability-support-to-the-kernel.patch
> 
> Yes, that's a good one to suspect.
> 
> What a peculiar error message.
> 
>> or so, and see if that's the problem.  If anyone has any other ideas, let me 
>> know.
> 
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFHPnlIQheEq9QabfIRAlglAKCG2NG1xnwMT8G/Lk8GoEPwtBzq9QCdFLYi
k+pt5Sd2AdtOJ+TjMIt1y6g=
=5wpX
-----END PGP SIGNATURE-----
