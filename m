From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC][patch 1/4] Network namespaces: cleanup of dev_base list use
Date: Tue, 27 Jun 2006 10:26:33 -0500
Message-ID: <20060627152633.GF24045@sergelap.austin.ibm.com>
References: <20060626134945.A28942@castle.nmd.msu.ru> <m1odwguez3.fsf@ebiederm.dsl.xmission.com> <44A0D755.5090204@sw.ru> <m11wtaonqf.fsf@ebiederm.dsl.xmission.com> <44A149F5.2060204@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andrey Savochkin <saw@swsoft.com>, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:30856 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1161097AbWF0P1b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:27:31 -0400
To: Kirill Korotaev <dev@sw.ru>
Content-Disposition: inline
In-Reply-To: <44A149F5.2060204@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Kirill Korotaev (dev@sw.ru):
> >>>>Cleanup of dev_base list use, with the aim to make device list 
> >>>>per-namespace.
> >>>>In almost every occasion, use of dev_base variable and dev->next pointer
> >>>>could be easily replaced by for_each_netdev loop.
> >>>>A few most complicated places were converted to using
> >>>>first_netdev()/next_netdev().
> >>>
> >>>As a proof of concept patch this is ok.
> >>>As a real world patch this is much too big, which prevents review.
> >>>Plus it takes a few actions that are more than replace just
> >>>iterators through the device list.
> >>
> >>Mmm, actually it is a whole changeset and should go as a one patch. I 
> >>didn't
> >>find it to be big and my review took only 5-10mins..
> >>I also don't think that mailing each driver maintainer is a good idea.
> >>Only if we want to make some buzz :)
> >
> >
> >Thanks for supporting my case.  You reviewed it and missed the obvious 
> >typo.
> >I do agree that a patchset doing it all should happen at once.
> This doesn't support anything. e.g. I caught quite a lot of bugs after 
> Ingo Molnar, but this doesn't make his code "poor". People are people.

Exactly - people are people, and they will do a better review of a
well-constructed set of small patches than of one large patch.  Eyes
glaze over, it just happens.

-serge
