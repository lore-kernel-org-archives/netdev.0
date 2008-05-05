From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Mon, 5 May 2008 11:18:00 -0500
Message-ID: <20080505161800.GC8485@sergelap.austin.ibm.com>
References: <20080429180445.GA18110@sergelap.austin.ibm.com> <20080429184151.GA19794@suse.de> <20080429193417.GA19282@sergelap.austin.ibm.com> <20080501031341.GD4911@suse.de> <20080501151051.GB16038@sergelap.austin.ibm.com> <m11w4lho08.fsf@frodo.ebiederm.org> <20080501210550.GA22534@sergelap.austin.ibm.com> <m1prs5fzzd.fsf@frodo.ebiederm.org> <20080502174222.GA16493@sergelap.austin.ibm.com> <481E4312.9060909@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <gregkh@suse.de>,
	Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Tejun Heo <htejun@gmail.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:41208 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754391AbYEEQSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 12:18:04 -0400
Content-Disposition: inline
In-Reply-To: <481E4312.9060909@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Daniel Lezcano (dlezcano@fr.ibm.com):
> Serge E. Hallyn wrote:
>> Quoting Eric W. Biederman (ebiederm@xmission.com):
>>> "Serge E. Hallyn" <serue@us.ibm.com> writes:
>>>
>>>> Quoting Eric W. Biederman (ebiederm@xmission.com):
>>>> Ok as it turns out Benjamin Thery does in fact have a patch to fix this.
>>>> Benjamin, please send your renaming patch out tomorrow if you can?
>>>>
>>>> I guess this is why I didn't really see the problem Benjamin said there
>>>> was - it just works with SYSFS_DEPRECATED  :)
>>> It will be nice to see that patch.  I'm curious what the problem was.
>>>
>>> Eric
>> Here is the patch he had privately sent.  As the comments indicate he's
>> still refining it so yell at me not him...   but this on top of the
>> tagged dir patchset makes everything work for me.
>> (I'd *really* like to see network namespaces be generally usable sometime
>> in 2.6.26.)
>
> Serge,
>
> I posted a fix to Dave Miller which was included in net-2.6 and merged in 
> 2.6.26-rc1.

Cool, I see it in gitweb, thanks.

> http://marc.info/?l=linux-netdev&m=120959135229360&w=2
>
> This one should fix your problem for sysfs.
>
> There is another fix to do in order to avoid name conflicts with network 
> interfaces belonging to different namespaces, eg. allows to rename veth1234 
> to eth0 without conflicting with the network device belonging in init_net, 
> I send this patch to container@ first to have it merged with the sysfs 
> patchset.

Ok.

Benjamin, what are you doing with Eric's sysfs patchset then?  Are you
going to re-post it asap on top of whatever tree has these two patches,
or are you planning to wait longer?

thanks,
-serge
