From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [RESEND][PATCH 00/11] sysfs tagged directories
Date: Tue, 06 May 2008 19:30:30 +0200
Message-ID: <20080506173030.653828076@theryb.frec.bull.fr>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50088 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759116AbYEFRg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:36:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is still the same port of Eric Biederman's patchset to implement
tagged directories in sysfs that was discussed a few days ago.

This time it applies on top of 2.6.26-rc1, 
which includes a fix from Daniel Lezcano to fix net device renaming
for sysfs (and of course all the network namespaces stuff that was 
committed in net-2.6.26).

This patchset still contains the patch from Serge Hallyn that implements
tagging for user namespaces.

It also contains a patch from Daniel Lezcano which allows to have net 
devices with the same name in two different network namespaces.


Here is what I said when I sent the patchset a few days ago:

> I re-post this patchset as most of network namespace work has been
> merged in net-2.6.26 and the issue is it is currently easy to test
> because of this missing piece.
> (today sysfs must be disabled to test netns).
>
>
>This feature is needed for network namespaces where we have to be able
>to have multiple network devices with the same name in different network
>namespaces. 
>
>On top of that, the final patch from Serge Hallyn also implements 
>tagging for user namespaces.
>
> Here is the announcement Eric wrote back in December to introduce his 
> patchset:

> "
> Now that we have network namespace support merged it is time to
> revisit the sysfs support so we can remove the dependency on !SYSFS.
> [...]
> The bulk of the patches are the changes to allow multiple sysfs
> superblocks.
>
> Then comes the tagged directory sysfs support which uses information
> captured at mount time to decide which object with which tag will
> appear in a directory.
>
> Then the support for renaming and deleting objects where the source
> may be ambiguous because of tagging.
>
> Then finally the network namespace support so it is clear how all
> of this tied together.
> "

Regards,
Benjamin
-- 
