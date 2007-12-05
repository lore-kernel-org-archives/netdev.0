From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 7/7] [TFRC] New rx history code
Date: Wed, 5 Dec 2007 13:34:49 +0000
Message-ID: <20071205133449.GB893@gerrit.erg.abdn.ac.uk>
References: <1196631416-17778-3-git-send-email-acme@redhat.com> <1196631416-17778-4-git-send-email-acme@redhat.com> <1196631416-17778-5-git-send-email-acme@redhat.com> <1196631416-17778-6-git-send-email-acme@redhat.com> <1196631416-17778-7-git-send-email-acme@redhat.com> <1196631416-17778-8-git-send-email-acme@redhat.com> <20071204065517.GA4404@gerrit.erg.abdn.ac.uk> <20071204115939.GA18084@ghostprotocols.net> <20071205093530.GA5177@gerrit.erg.abdn.ac.uk> <20071205120801.GN29972@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:36432 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751439AbXLENfs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 08:35:48 -0500
Content-Disposition: inline
In-Reply-To: <20071205120801.GN29972@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > In the end this went back to the same questions and issues that were tackled between
| > February and March this year. I wish we could have had this dicussion then; it would
| > have made this email unnecessary.
| 
| That is why it is important that the changeset comment collects these
| scattered notes and discussions. Think about in some years from now we
| will be left with a situation where we would have to look at many places
| to understando some aspects of what is in the code. While this happens
| and we have google for that I think that since you keep such detailed
| notes it is not a problem to get them in the changesets.
|  
I agree, the changelogs are all a bit short. When condensing from 40 to 16 patches the changelogs
were also cut down, for fear of being too verbose. Will go through the patches in the next days and
see if/where this can be improved, that would probably have saved some trouble.

| >  * But where I need to interact is when changes are made to the algorithm, even if these may 
| >    seem small. The underlying reasons that lead to the code may not be immediately clear,
| >    but since this is a solution for a specific problem, there are also specific reasons; which
| >    is why for algorithm changes (and underlying data structure) I'd ask you to discuss this first
| >    before committing the patch. 
| 
| I did this for the RX handling, where changes were made. Did that for
| the TX but ended up commiting before comments from you, but I think its
| fair to say that the changes for the TX history were more organizational
| than in the essence of the algorithm.
|  
It was a similar situation: the RFC patch came out on Thursday afternoon; I replied a bit hurriedly
on Friday that it seemed ok, but found the full confirmation only on Sunday after putting all
recent changes into the test tree. And yes, you made a good job of it.
