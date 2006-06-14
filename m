From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC/PATCH 1/2] in-kernel sockets API
Date: Wed, 14 Jun 2006 10:48:56 -0700
Message-ID: <44904C08.6020307@google.com>
References: <1150156562.19929.32.camel@w-sridhar2.beaverton.ibm.com> <20060613140716.6af45bec@localhost.localdomain> <20060613052215.B27858@openss7.org> <448F2A49.5020809@google.com> <20060614133022.GU11863@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bidulock@openss7.org, Stephen Hemminger <shemminger@osdl.org>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:9957 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP id S932235AbWFNRtY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 13:49:24 -0400
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20060614133022.GU11863@sunbeam.de.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Harald,

You wrote:
> On Tue, Jun 13, 2006 at 02:12:41PM -0700, I wrote:
> 
>>This has the makings of a nice stable internal kernel api.  Why do we want
>>to provide this nice stable internal api to proprietary modules?
> 
> because there is IMHO legally nothing we can do about it anyway.

Speaking as a former member of a "grey market" binary module vendor that
came in from the cold I can assure you that the distinction between EXPORT
and EXPORT_GPL _is_ meaningful.  That tainted flag makes it extremely
difficult to do deals with mainstream Linux companies and there is always
the fear that it will turn into a legal problem.  The latter bit tends to
make venture capitalists nervous.

That said, the EXPORT_GPL issue is not about black and white legal issues,
it is about gentle encouragement.  In this case we are offering a clumsy,
on-the-metal, guaranteed-to-change-and-make-you-edit-code interface to
non-GPL-compatible modules and a decent, stable (in the deserves to live
sense) interface for the pure of heart.  Gentle encouragement at exactly
the right level.

Did we settle the question of whether these particular exports should be
EXPORT_SYMBOL_GPL?

Regards,

Daniel
