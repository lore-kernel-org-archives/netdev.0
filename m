From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] fix multi-buffer logging with mergeable buffers
Date: Sun, 9 May 2010 08:46:03 -0700
Message-ID: <OFE4F4080B.63752BF0-ON8825771E.00556A03-8825771E.00569BA4@us.ibm.com>
References: <20100509111016.GA19453@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:36102 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016Ab0EIPqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 May 2010 11:46:06 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o49FbSED026999
	for <netdev@vger.kernel.org>; Sun, 9 May 2010 09:37:28 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o49Fk59e122010
	for <netdev@vger.kernel.org>; Sun, 9 May 2010 09:46:05 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o49FmtIa014635
	for <netdev@vger.kernel.org>; Sun, 9 May 2010 09:48:55 -0600
In-Reply-To: <20100509111016.GA19453@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/09/2010 04:10:16 AM:

> On Fri, May 07, 2010 at 01:11:08PM -0700, David L Stevens wrote:
> > This patch fixes the multibuffer case of logging with
> > mergeable buffers.
> > 
> > Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
> 
> So, I folded this into your original patch submission,
> this way we don't get broken logging followed
> by a fix (better for bisect). Further, I think it's better to only use 
log_num
> on success. After fixing whitespace (+ needs space around it:
> didn't checkpatch complain?) I merged the below,
> and rebased my tweaks patch on top.
> 
> The result can be found here:
> git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git 
vhost-mrg-rxbuf
> 
> Compiles fine but I'm a bit busy with other things,
> and didn't test at all yet, I'd appreciate testing and reports.

        Looks good, and works. Thanks!

                                        +-DLS


