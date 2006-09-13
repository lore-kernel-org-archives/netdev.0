From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] make ipv4 multicast packets only get delivered to
	sockets	that are joined to group
Date: Wed, 13 Sep 2006 12:12:23 -0400
Message-ID: <1158163943.15449.75.camel@dantu.rdu.redhat.com>
References: <OF0C86B64A.DE64FE98-ON882571E8.004F57A7-882571E8.004FDDED@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:2695 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750958AbWIMQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 12:12:32 -0400
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF0C86B64A.DE64FE98-ON882571E8.004F57A7-882571E8.004FDDED@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-13 at 07:32 -0700, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 09/13/2006 07:13:55 AM:
>
>         This is not true on any OS I'm aware of, including the
> original sockets multicast implementation on early BSD.
> 

The current Linux behavior does seem to be consistent with the way
recent BSD and OSX seem to work. Solaris 8 seems to behave consistent
with the patch I posted.

Most of the RFC's I've looked at don't seem to have much to say about
how multicasting works at the socket level. Is there an RFC or
specification that spells this out, or is this one of those situations
where things are somewhat open to interpretation?

Thanks,
Jeff


