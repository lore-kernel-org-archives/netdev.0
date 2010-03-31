From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/6] tagged sysfs support
Date: Wed, 31 Mar 2010 15:25:09 +0900
Message-ID: <4BB2EAC5.30900@kernel.org>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org> <ac3eb2511003301153i43a60720hb015071e2c992199@mail.gmail.com> 	<m14ojxh0mz.fsf@fess.ebiederm.org> <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, netdev@vger.kernel.org
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:45421 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756156Ab0CaGWI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Mar 2010 02:22:08 -0400
In-Reply-To: <s2hac3eb2511003302251rcbae8767ne21e9daf1546c849@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2010 02:51 PM, Kay Sievers wrote:
> Another problem to solve is that sysfs does not allow us to symlink
> regular files, only directories, so we can currently not create the
> class-wide attributes as symlinks to the proper file in
> /sys/subsystem/.

Making sysfs allow symlinks to attributes shouldn't be too hard if
it's gonna help make things more logical overall.

Thanks.

-- 
tejun
