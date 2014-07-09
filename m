From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/5] SCTP updates
Date: Wed, 9 Jul 2014 11:12:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726F0E9@AcuExch.aculab.com>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
 <20140708111408.GA23026@hmsreliant.think-freely.org>
 <53BBFAA6.80408@redhat.com>
 <20140708144127.GB23026@hmsreliant.think-freely.org>
 <53BD1211.4080504@redhat.com>
 <20140709104958.GA3784@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57820 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755313AbaGILNk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 07:13:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04345-06 for <netdev@vger.kernel.org>;
 Wed,  9 Jul 2014 12:13:31 +0100 (BST)
In-Reply-To: <20140709104958.GA3784@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
> > In how many years do you plan a removal ... I think we're stuck with uapi
> > basically forever as we don't want to break old binaries, no? ;/
> >
> I thought we could remove things on a schedule if we followed the deprecation
> process, but that may just be for sysfs.  Regardless, it would still be nice to
> inform people they are using an older api.

The issue here is that it is an application API, not a system programming one.
I'd guess that most sysfs stuff is only used by programs that are released
as part of a Linux distribution - and thus code that is likely to be
release with a matching kernel.

These sccp structures are much more likely to be used by 'proper' 3rd party
applications, targeted at multiple kernel versions - possibly in binary form.
We compile applications on the oldest linux version we think our customers
are using - otherwise we'd have to release multiple copies.

So I don't think they can be deprecated (with warnings from the kernel) for
a long time, perhaps 5 or 10 years!

The first stage would be (somehow) to generate warnings when applications
are compiled. Only when that has been in place for some time would it
make sense to generate kernel warnings.

		David
