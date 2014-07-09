From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/5] SCTP updates
Date: Wed, 9 Jul 2014 16:02:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1726F39D@AcuExch.aculab.com>
References: <1404507908-6949-1-git-send-email-dborkman@redhat.com>
 <20140708111408.GA23026@hmsreliant.think-freely.org>
 <53BBFAA6.80408@redhat.com>
 <20140708144127.GB23026@hmsreliant.think-freely.org>
 <53BD1211.4080504@redhat.com>
 <20140709104958.GA3784@hmsreliant.think-freely.org>
 <53BD4363.70306@redhat.com> <20140709151354.GA5250@localhost.localdomain>
 <53BD6167.1030000@gmail.com> <20140709154428.GD5250@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"geirola@gmail.com" <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Neil Horman' <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34849 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755658AbaGIQDe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 12:03:34 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 30994-02 for <netdev@vger.kernel.org>;
 Wed,  9 Jul 2014 17:03:26 +0100 (BST)
In-Reply-To: <20140709154428.GD5250@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman
...
> > The problem here is deprecation of ancillary data and that's is a lot tougher
> > then socket options.  In this particular case (SCTP_SNDRCVINFO vs SCTP_RCVINFO),
> > I don't think there is any way to deprecate the SCTP_SNDRCVINFO since the event
> > enabling it is the same as the one for SCTP_RCVINFO.  This was a mistake in the
> > spec.  Ancillary data should not have been enabled using even notification api,
> > as it is not an event, but we now have to live with it.
> >
> Ugh I didn't even consider cmsg type overlap.  Thats probably it then, we can't
> deprecate it.  Though that does call the question up as to how to differentiate
> expectations of the data format for each cmsg, if they use the same type.  Does
> the SCTP_RCVINFO data struct overlay the SNDRCVINFO struct exactly?  (sorry I've
> not checked myself yet).

Not from what I remember from when I read that RFC.
I think the lengths are different enough to determine which is which.

That RFC (I've forgotten the number) looks like an entire bag of poo
that should be ignored...

	David
