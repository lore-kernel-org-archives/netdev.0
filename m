From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network namespace website
Date: Fri, 06 Apr 2007 15:03:20 -0600
Message-ID: <m164895i7b.fsf@ebiederm.dsl.xmission.com>
References: <46164A9E.2090705@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	David Stevens <dlstevens@us.ibm.com>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36476 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933006AbXDFVH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 17:07:59 -0400
In-Reply-To: <46164A9E.2090705@fr.ibm.com> (Daniel Lezcano's message of "Fri,
	06 Apr 2007 15:26:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Hi,
>
> Eric Biederman has posted a few weeks ago a RFC-patchset concerning the 
> network namespace.
> I ported it to the 2.6.20 kernel and uploaded the patchset to
>
> http://lxc.sourceforge.net/network.php
>
> For the part I had to used (TCP/UDP-IPV4 with usual ethernet device), I 
> found the patchset pretty stable.
>
> You can find in the website:
>
>     - a global description of what is the network namespace
>     - a howto for the network namespace configuration
>     - a benchmarking matrix
>     - the network namespace patchset for 2.6.20 kernel
>
> I hope that can helps to answer what is ? , what for ?, how to use ? 
> questions.
>
> If you have any questions or feedbacks, feel free to send an email to 
> containers@ mailing list

An updated version with hopefully all of the fixes applied and merged
based into the proper patches and against against 2.6.21-rc6 is available at:

git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-2.6-netns.git

After finally getting the sysfs support back under control I have finished
rebasing my original patchset.

Eric
