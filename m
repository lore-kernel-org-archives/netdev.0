From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 01/23] configfs: add show and store methods to struct
 configfs_attribute
Date: Sat, 26 Sep 2015 16:38:55 -0700
Message-ID: <1443310735.7042.25.camel@haakon3.risingtidesystems.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
	 <1443189000-13398-2-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:40660 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbIZXi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 19:38:57 -0400
In-Reply-To: <1443189000-13398-2-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-25 at 06:49 -0700, Christoph Hellwig wrote:
> Add methods to struct configfs_attribute to directly show and store
> attributes without adding boilerplate code to every user.  In addition
> to the methods this also adds 3 helper macros to define read/write,
> read-only and write-only attributes with a single line of code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/configfs/file.c       | 17 ++++++++++++-----
>  include/linux/configfs.h | 27 +++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+), 5 deletions(-)
> 

Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>
