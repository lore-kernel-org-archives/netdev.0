From: Andy Isaacson <adi@hexapodia.org>
Subject: Re: netdev-2.6 queue updated
Date: Thu, 27 Jan 2005 18:15:30 -0800
Message-ID: <20050128021530.GB19150@hexapodia.org>
References: <41F980A0.8020905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@osdl.org>, Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41F980A0.8020905@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 07:00:32PM -0500, Jeff Garzik wrote:
> The attached changelog describes what I just pushed out to BitKeeper 
> (and what should be appearing in the next -mm release from Andrew).
> 
> Note to BK users:  please re-clone netdev-2.6, don't just 'bk pull'.

It's much more efficient to do
% bk undo -a`bk repogca`
(which deletes everything in the local repo that's not in the parent)
rather than pulling the entire repo over the wire again. [1]

You can check what would be deleted by this command with "bk changes -L"
similar to how you can "bk changes -R" to figure out what would be
pulled.

[1] Well, actually, it isn't *quite* that simple; in certain cases,
    repogca will delete more than it needs to.  But it's still more
    efficient than a re-pull.

-andy
