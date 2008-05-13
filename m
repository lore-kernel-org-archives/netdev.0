From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: kobject: Fix kobject_rename and !CONFIG_SYSFS
Date: Tue, 13 May 2008 13:42:59 -0700
Message-ID: <m1wsly9bqk.fsf@frodo.ebiederm.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net> <20080513164438.GA31563@kroah.com>
	<20080513213330.utev64tlw4ss0kgw@intran0x.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Benjamin Thery " <Benjamin.Thery@bull.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42100 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757542AbYEMUuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 16:50:21 -0400
In-Reply-To: <20080513213330.utev64tlw4ss0kgw@intran0x.frec.bull.fr> (Benjamin
	Thery's message of "Tue, 13 May 2008 21:33:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Benjamin Thery " <Benjamin.Thery@bull.net> writes:

> That's what I did first. But I thought it was worse than the above
> solution.
> Anyway, adding kobject_set_name() to sysfs.h did fix the error.

I figure sorting out the headers is worth while, but that is
another project.

Because kobject.h includes sysfs.h we can't get the declarations
out of sync which is the really important part.

Eric
