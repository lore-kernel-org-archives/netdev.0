From: Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>
Subject: Re: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v3
Date: Tue, 13 May 2008 16:18:55 -0500 (CDT)
Message-ID: <24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net> <20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<20080513201602.GA31578@kroah.com> <m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44876 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbYEMVW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 17:22:56 -0400
In-Reply-To: <m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Changelog:
> v3:	Documentation typo fixes

Inserted/attached wrong patch file?
I don't see any text changes.


> diff --git a/Documentation/kobject.txt b/Documentation/kobject.txt
> index bf3256e..79184b4 100644
> --- a/Documentation/kobject.txt
> +++ b/Documentation/kobject.txt
> @@ -118,6 +118,10 @@ the name of the kobject, call kobject_rename():
>  
>      int kobject_rename(struct kobject *kobj, const char
> *new_name);
>  
> +Note kobject_rename does perform any locking or have a solid
> notion of
> +what names are valid so the provide must provide their own
> sanity checking
> +and serialization.
> +
>  There is a function called kobject_set_name() but that is
> legacy cruft and
>  is being removed.  If your code needs to call this function,
> it is
>  incorrect and needs to be fixed.

