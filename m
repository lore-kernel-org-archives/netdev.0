From: Doug Maxey <dwm@enoyolf.org>
Subject: Re: kernel doc / docbook pdfdocs question
Date: Thu, 01 Oct 2009 00:42:27 -0500
Message-ID: <27289.1254375747@jerryjeff.riw.enoyolf.org>
References: <8223.1254340776@jerryjeff.riw.enoyolf.org> <20090930173002.36da7ffd@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iggy.enoyolf.org ([24.173.215.189]:39952 "EHLO
	jerryjeff.riw.enoyolf.org" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751690AbZJAFm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 01:42:27 -0400
In-reply-to: <20090930173002.36da7ffd@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 30 Sep 2009 17:30:02 PDT, Stephen Hemminger wrote:
>On Wed, 30 Sep 2009 14:59:36 -0500
>Doug Maxey <dwm@enoyolf.org> wrote:
>
>> 
>> Randy,
>> 
>> This may be slightly off topic for this list, but it does involve an
>> (as yet un-released) network driver. :)
>> 
>> Do you have any insight that could guide me toward a fix for an issue
>> seen with some header file constructs when trying to generate a pdf
>> docbook?
>> 
>
>Why clutter docbook output (which is supposed to be about general kernel
>API's) with output for data structures in one driver.

It would be a general mechanism, and it would be to document an API.
There are other subsystems that use DECLARE_BITMAP() (e.g., scsi).
Just none at the moment that attempt to describe such a member,
possibly because there isn't a way to document it.  Dunno.  Build it
and they will come.  There is one party that is interested anyway.

Finally did find where this was getting warned about / tossed, in
kernel-doc itself. =)

++doug


