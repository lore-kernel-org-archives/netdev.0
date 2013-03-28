From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] iproute: Faster ip link add, set and delete
Date: Wed, 27 Mar 2013 20:44:40 -0700
Message-ID: <87vc8cnq6v.fsf@xmission.com>
References: <CD78B3C3.76D3%blourdel@juniper.net> <874nfwri6o.fsf@xmission.com>
	<20130327104746.0ec9dcb5@nehalam.linuxnetplumber.net>
	<87620cpd0y.fsf@xmission.com> <20130328032046.GA32083@sergelap>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Benoit Lourdelet <blourdel@juniper.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55866 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754904Ab3C1Dov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 23:44:51 -0400
In-Reply-To: <20130328032046.GA32083@sergelap> (Serge Hallyn's message of
	"Wed, 27 Mar 2013 22:20:46 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Serge Hallyn <serge.hallyn@ubuntu.com> writes:

> Quoting Eric W. Biederman (ebiederm@xmission.com):
>> Stephen Hemminger <stephen@networkplumber.org> writes:
>> 
>> > If you need to do lots of operations the --batch mode will be significantly faster.
>> > One command start and one link map.
>> 
>> The problem in this case as I understand it is lots of independent
>> operations. Now maybe lxc should not shell out to ip and perform the
>> work itself.
>
> fwiw lxc uses netlink to create new veths, and picks random names with
> mktemp() ahead of time.

I am puzzled where does the slownes in iproute2 come into play?

Eric
