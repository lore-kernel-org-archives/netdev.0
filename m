From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] v9fs: rename non-vfs related structs and functions
 to be moved to net/9p
Date: Tue, 8 May 2007 14:10:12 -0700
Message-ID: <20070508141012.7fdf4c24.akpm@linux-foundation.org>
References: <f158dc670705081351j4d46b433o2bdd2e8212a52e15@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel" <linux-kernel@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org,
	"V9FS Developers" <v9fs-developer@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: "Latchesar Ionkov" <lucho@ionkov.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:54171 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1032193AbXEHVK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 17:10:56 -0400
In-Reply-To: <f158dc670705081351j4d46b433o2bdd2e8212a52e15@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007 14:51:02 -0600
"Latchesar Ionkov" <lucho@ionkov.net> wrote:

> This patchset moves non-filesystem interfaces of v9fs from fs/9p to net/9p.
> It moves the transport, packet marshalling and connection layers to net/9p
> leaving only the VFS related files in fs/9p.

(Please cc netdev@vger.kernel.org on net-related work)

These changes would be best handled via Eric's git tree, with appropriate
acks from the net maintainers.
