From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Fri, 04 Jul 2008 06:31:29 -0700
Message-ID: <m1tzf593ny.fsf@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<m14p78s02q.fsf@frodo.ebiederm.org> <486C4515.1070007@gmail.com>
	<m1hcb7o8lv.fsf@frodo.ebiederm.org> <486CB051.5000507@fr.ibm.com>
	<m14p77m9uy.fsf@frodo.ebiederm.org> <486CF71F.5090405@gmail.com>
	<m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>
	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59814 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020AbYGDNl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 09:41:58 -0400
In-Reply-To: <486DD650.3000804@gmail.com> (Tejun Heo's message of "Fri, 04 Jul
	2008 16:50:40 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thank you for your opinion.

Incremental patches to make things more beautiful are welcome.

Please remember we are not building lisp.  The goal is code that works today.

Since we are not talking about correctness of the code.  Since we are not
talking about interfaces with user space.  Since we are talking something
that is currently about 100 lines of code, and so will be easy to change
even after it is merged.   I don't understand how discussing this further
is useful.  Especially when I get a NAK  based on the feel that the code
is ugly.

As for your main objection.  Adding a accessor method to an object versus
adding a data field that contain the same thing.  The two are effectively
identical.  With the practical difference in my eyes that an accessor method
prevents data duplication which reduces maintenance and reduces skew problems,
and it keeps the size of struct kobject small.  Since you think methods are
horrible I must respectfully disagree with you.

Eric
