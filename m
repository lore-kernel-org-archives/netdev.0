From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/4] vfs: Export some file manipulation functions
Date: Wed, 21 Dec 2011 10:30:54 -0500
Message-ID: <20111221153054.GA1489@infradead.org>
References: <1324478390-22036-1-git-send-email-nhorman@tuxdriver.com>
 <1324478390-22036-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-fsdevel@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1324478390-22036-3-git-send-email-nhorman@tuxdriver.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2011 at 09:39:48AM -0500, Neil Horman wrote:
> the networking cgroups can use the fd table of a task to make adjustments to the
> sockets that they own, helping us set owners for various resources. Export
> get_files_struct, put_files_struct and sock_from_file, so we can walk a tasks
> fdarray easily.

No, no one has any business using these lowlevel routines form modules.

Please find a way to do this in core code, or find more highlevel
primitives to export.

And not even Ccing linux-fsdevel on a change like this is one of the few
things I'd consider extremely offensive.

