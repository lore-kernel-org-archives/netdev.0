From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 10/11] avoid kobject name conflict with different namespaces
Date: Thu, 08 May 2008 12:28:19 -0700
Message-ID: <m1myn0d298.fsf@frodo.ebiederm.org>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	<20080506173335.922289888@theryb.frec.bull.fr>
	<m13aoueyq8.fsf@frodo.ebiederm.org> <20080507190838.GA4467@suse.de>
	<m1hcd9esxo.fsf@frodo.ebiederm.org>
	<20080508102844.25642ef7@gondolin.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:48718 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbYEHTaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 15:30:04 -0400
In-Reply-To: <20080508102844.25642ef7@gondolin.boeblingen.de.ibm.com>
	(Cornelia Huck's message of "Thu, 8 May 2008 10:28:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cornelia Huck <cornelia.huck@de.ibm.com> writes:

> On Wed, 07 May 2008 13:54:27 -0700,
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> > I thought that s390 also used it, but I don't see
>> > that usage in the tree anymore, perhaps they switched to something else.
>> 
>> That is the device_move -> kobject_move case. 
>
> Yes. bluetooth also uses it, IIRC.

Yes.

>> Very similar (and nice
>> if we can figure out how to combine them).
>
> Sounds like a good idea. I can test the _move() stuff (after I've
> managed to find some time to try this patchset...)

Do you remember if we have ever sorted out the race between _move
and module unload/directory teardown at the sysfs level?

Eric
