From: "Jonathan Larsen" <agentc0re@gmail.com>
Subject: Re: Fwd: r8169 driver supporting the 8167 dev ID
Date: Sat, 14 Jul 2007 11:02:20 -0600
Message-ID: <71421f560707141002w592a18cfqf8a9ba34745e75c6@mail.gmail.com>
References: <71421f560707091922y60dec801w836e1e4e88c36de2@mail.gmail.com>
	 <71421f560707091923y64565c84wecb1229c219642c4@mail.gmail.com>
	 <20070710212513.GB3436@electric-eye.fr.zoreil.com>
	 <71421f560707101724x42fb6c8ye82bd08a9c7bca5@mail.gmail.com>
	 <71421f560707110605x1bf79d7dj73ce7edd590b58ce@mail.gmail.com>
	 <20070711192850.GA4904@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.236]:57186 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755588AbXGNRCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 13:02:21 -0400
Received: by wx-out-0506.google.com with SMTP id h31so770407wxd
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2007 10:02:20 -0700 (PDT)
In-Reply-To: <20070711192850.GA4904@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You should read the tutorial until you find the 'Using git for collaboration'
> part. You missed a:
>
> git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Alright sweet, i got somewhere :).  i was able to pull that down, do
my previous steps and git commit  and then the git format patch and it
pulled down a whole bunch of .patch files.
i've seen them before.  they also exist here.
http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00/broken-out/
Im confused as what i would need to do with these files.  would i run
them as a patch against the r8169.c file?  ie: patch p1 < 'one of the
patch files.patch'?
the other thing i've ran into trouble with is getting the git kernel
version for 2.6.16.52.  i've searched for a 2.6.16.52.git file and
haven't seen anything and also tried using get pull v2.6.16.52 and i
get a fatal error.  unable to chdir or not a git archive.  i've also
tried without the .52 and get the same thing.

> v2.6.23-rc1 is not available yet. Replace it with 'master' or, say,
> 4eb6bf6bfb580afaf1e1a1d30cba17a078530cf4

i just used v.2.6.22.

> PS: please trim the irrelevant parts in your reply and do not top post.

Sorry, about that.  gmail hides previous emails.

i just want to make sure it was understood that i want try and make
the r8169 driver that supported my card in 2.6.22 and back port it to
work in 2.6.16.52.
