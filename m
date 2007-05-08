From: "Eric Van Hensbergen" <ericvh@gmail.com>
Subject: Re: [V9fs-developer] [PATCH 1/4] v9fs: rename non-vfs related structs and functions to be moved to net/9p
Date: Tue, 8 May 2007 17:07:05 -0500
Message-ID: <a4e6962a0705081507u39ab95c6oee147ac3e453624a@mail.gmail.com>
References: <f158dc670705081351j4d46b433o2bdd2e8212a52e15@mail.gmail.com>
	 <20070508141012.7fdf4c24.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Latchesar Ionkov" <lucho@ionkov.net>,
	linux-fsdevel@vger.kernel.org,
	"V9FS Developers" <v9fs-developer@lists.sourceforge.net>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:57662 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbXEHWHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 18:07:06 -0400
Received: by nz-out-0506.google.com with SMTP id o1so2154186nzf
        for <netdev@vger.kernel.org>; Tue, 08 May 2007 15:07:05 -0700 (PDT)
In-Reply-To: <20070508141012.7fdf4c24.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/8/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Tue, 8 May 2007 14:51:02 -0600
> "Latchesar Ionkov" <lucho@ionkov.net> wrote:
>
> > This patchset moves non-filesystem interfaces of v9fs from fs/9p to net/9p.
> > It moves the transport, packet marshalling and connection layers to net/9p
> > leaving only the VFS related files in fs/9p.
>
> (Please cc netdev@vger.kernel.org on net-related work)
>
> These changes would be best handled via Eric's git tree, with appropriate
> acks from the net maintainers.
>

Ack.  I was waiting to see if Lucho hit any major brick walls with the
community before pulling them in.

                -eric
