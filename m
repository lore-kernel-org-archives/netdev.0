From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [RESEND][PATCH 00/11] sysfs tagged directories
Date: Tue, 6 May 2008 20:41:33 +0200
Message-ID: <939d53060805061141g3803a380j50ca89f39dbf0fe6@mail.gmail.com>
References: <20080506173030.653828076@theryb.frec.bull.fr>
	 <20080506175331.GA1815@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Thery" <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Tejun Heo" <htejun@gmail.com>, "Al Viro" <viro@ftp.linux.org.uk>,
	"Daniel Lezcano" <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	"Pavel Emelyanov" <xemul@openvz.org>, netdev@vger.kernel.org
To: "Greg KH" <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:37958 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759062AbYEFSld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:41:33 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1812890rvb.1
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 11:41:33 -0700 (PDT)
In-Reply-To: <20080506175331.GA1815@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 6, 2008 at 7:53 PM, Greg KH <gregkh@suse.de> wrote:
> On Tue, May 06, 2008 at 07:30:30PM +0200, Benjamin Thery wrote:
>  > This is still the same port of Eric Biederman's patchset to implement
>  > tagged directories in sysfs that was discussed a few days ago.
>  >
>  > This time it applies on top of 2.6.26-rc1,
>  > which includes a fix from Daniel Lezcano to fix net device renaming
>  > for sysfs (and of course all the network namespaces stuff that was
>  > committed in net-2.6.26).
>  >
>  > This patchset still contains the patch from Serge Hallyn that implements
>  > tagging for user namespaces.
>  >
>  > It also contains a patch from Daniel Lezcano which allows to have net
>  > devices with the same name in two different network namespaces.
>
>  Does this all work properly with both CONFIG_SYSFS_DEPRECATED enabled
>  and disabled?

Yes.
I tested both cases and with my limited knowledge of sysfs (I'm mostly
interested in /sys/class/net population), this looked fine to me.

>
>  Can you show some outputs of 'tree' in both cases on the /sys/class/net/
>  directory?

Sure.
I hope you don't mind if I'll send them tomorrow I'm back home right now
and have limited access to my test machines.

-benjamin

>
>  thanks,
>
>  greg k-h
>
>
> --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
