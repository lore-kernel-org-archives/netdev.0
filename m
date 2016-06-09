From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time()
 for inode timestamps
Date: Thu, 9 Jun 2016 09:55:39 +0200
Message-ID: <20160609075539.GF3905@suse.cz>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Reply-To: dsterba@suse.cz
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Colin Cross <ccross@android.com>, Arnd Bergmann <arnd@arndb.de>,
	pvfs2-developers@beowulf-underground.org,
	Kees Cook <keescook@chromium.org>,
	Matt Fleming <matt@codeblueprint.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Boaz Harrosh <ooo@electrozaur.com>,
	Anton Vorontsov <anton@enomsg.org>,
	Joel Becker <jlbec@evilplan.org>, Chris Mason <clm@fb.com>,
	Josef Bacik <jbacik@fb.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Firo Yang <firogm@gmail.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Prasad Joshi <prasadjoshi.linux@gmail.com>,
	Hugh Dickins <hughd@google.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nadia Yvette Chambers <nyc@holomorphy.com>,
	Peter Hurley <peter@hurleysof
To: Deepa Dinamani <deepa.kernel@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 08, 2016 at 10:04:48PM -0700, Deepa Dinamani wrote:
> CURRENT_TIME macro is not appropriate for filesystems as it
> doesn't use the right granularity for filesystem timestamps.
> Use current_fs_time() instead.
> 
> CURRENT_TIME is also not y2038 safe.
> 
> This is also in preparation for the patch that transitions
> vfs timestamps to use 64 bit time and hence make them
> y2038 safe. As part of the effort current_fs_time() will be
> extended to do range checks. Hence, it is necessary for all
> file system timestamps to use current_fs_time(). Also,
> current_fs_time() will be transitioned along with vfs to be
> y2038 safe.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: David Sterba <dsterba@suse.com>

for the btrfs bits

Reviewed-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
