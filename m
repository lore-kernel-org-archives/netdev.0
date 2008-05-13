From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: kobject: Fix kobject_rename and !CONFIG_SYSFS
Date: Tue, 13 May 2008 00:00:06 -0700
Message-ID: <m1prrqbseh.fsf@frodo.ebiederm.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Tejun Heo <htejun@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46012 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244AbYEMHKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 03:10:13 -0400
In-Reply-To: <20080512220232.GA16914@kroah.com> (Greg KH's message of "Mon, 12
	May 2008 15:02:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

>
> Eric, Randy Dunlap has found that this patch breaks the build when
> CONFIG_SYSFS is not enabled.  Can you please fix it up before I send it
> to Linus?
>
> The exact error is:
> In file included from /local/linsrc/next-20080509/include/linux/kobject.h:21,
>                  from /local/linsrc/next-20080509/include/linux/module.h:16,
>                  from /local/linsrc/next-20080509/include/linux/crypto.h:21,
>                  from
> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets_64.c:7,
>                  from
> /local/linsrc/next-20080509/arch/x86/kernel/asm-offsets.c:4:
> /local/linsrc/next-20080509/include/linux/sysfs.h: In function
> 'sysfs_rename_dir':
> /local/linsrc/next-20080509/include/linux/sysfs.h:142: error: implicit
> declaration of function 'kobject_set_name'

I will take a look in the morning and see if I can see what is wrong.

Which tree was this error against?  I thought I tested this case,
and I'm wondering if there might be another patch that is hiding
kobject_set_name.

Eric
