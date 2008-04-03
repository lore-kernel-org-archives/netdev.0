From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: Three TCP/IP warnings in 2.6.25-rc7-git1
Date: Wed, 02 Apr 2008 22:40:47 -0700
Message-ID: <47F46DDF.90304@linux.intel.com>
References: <47F15200.3060706@linux.intel.com>	<47F46945.40500@linux.intel.com> <20080402.222846.92587028.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:55163 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756126AbYDCFsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 01:48:52 -0400
In-Reply-To: <20080402.222846.92587028.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Wed, 02 Apr 2008 22:21:09 -0700
> 
>> It would be not so nice to ship a 2.6.25 that triggers these frequently,
>> it has the risk of causing many user bugreports to this list and other
>> places...
> 
> I wouldn't call it frequently, on at least an individual basis,
> because nobody we try to get feedback from can reproduce this
> reliably.  That's the only reason this isn't fixed yet, despite
> all of Ilpo's efforts.

(first of all I'm not trying to say you guys aren't trying; I know chasing such stuff is
really hard; I'm just trying to help by giving information on when/what it happens, and that it hasn't been
reported prior to 2.6.24-rc4 for example)

What I meant by frequently is that the fedora rawhide users have seen this 24 times
in the last 7 days. The Fedora rawhide userbase is a lot smaller than the total userbase of
what will be the 2.6.25 kernel, so I suspect that the total number of people who'll find
this at least once when 2.6.25 goes out is likely to be much higher...
(to counter that.. it's a WARN_ON so it's a good question if those people will actually see it and
then report it)

I didn't mean it in the sense that one person sees it all the time.
(Which would obviously MUCH nicer debugging wise)

If there's a way to add more WARN_ON's to places that are suspect that would work; via kerneloops.org
there'll be at least statistical information if those places hit (and possibly they can be correlated
to these warnings happening). This doesn't mean you'll have someone who can try this and say it goes away,
but it also means the testbase for this is a lot wider... eg when the fish are rare, cast a wider net.
