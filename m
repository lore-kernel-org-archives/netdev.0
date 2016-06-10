From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with
	current_fs_time() for inode timestamps
Date: Sat, 11 Jun 2016 00:23:39 +0200
Message-ID: <3828814.bejVmX1kJo__40680.5351296954$1465611492$gmane$org@wuerfel>
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
	<1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Latchesar Ionkov <lucho@ionkov.net>, Dave Kleikamp <shaggy@kernel.org>,
	jfs-discussion@lists.sourceforge.net, Michal Hocko <mhocko@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Matt Fleming <matt@codeblueprint.co.uk>, Firo Yang <firogm@gmail.com>,
	Trond Myklebust <trond.myklebust@primarydata.com>,
	Alexei Starovoitov <ast@kernel.org>, David Howells <dhowells@redhat.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>, linux-efi@vger.kernel.org,
	selinux@tycho.nsa.gov, Eric Paris <eparis@parisplace.org>,
	Matthew Garrett <matthew.garrett@nebula.com>,
	Jeff Layton <jlayton@poochiereds.net>,
	linux-f2fs-devel@lists.sourceforge.net,
	Sean Hefty <sean.hefty@intel.com>, Ian Kent <raven@themaw.net>,
	linux-cifs@vger.kernel.org, Paul Moore <paul@paul-moore.com>,
	"David S. Miller" <davem@davemloft.net>, y2038@lists.linaro.org,
	Anton Vorontsov <anton@enomsg.org>, Hugh Dickins <hughd@
To: Deepa Dinamani <deepa.kernel@gmail.com>,
	Mike Marshall <hubcap@omnibond.com>,
	Nadia Yvette Chambers <nyc@holomorphy.com>,
	Chao Yu <chao2.yu@samsung.com>, linux-nilfs@vger.kernel.org
Return-path: <jfs-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=jfs-discussion>
List-Post: <mailto:jfs-discussion@lists.sourceforge.net>
List-Help: <mailto:jfs-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: jfs-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday, June 8, 2016 10:04:48 PM CEST Deepa Dinamani wrote:
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: Steve French <sfrench@samba.org>
> Cc: linux-cifs@vger.kernel.org
> Cc: samba-technical@lists.samba.org
> Cc: Joern Engel <joern@logfs.org>
> Cc: Prasad Joshi <prasadjoshi.linux@gmail.com>
> Cc: logfs@logfs.org
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Julia Lawall <Julia.Lawall@lip6.fr>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Firo Yang <firogm@gmail.com>
> Cc: Jaegeuk Kim <jaegeuk@kernel.org>
> Cc: Changman Lee <cm224.lee@samsung.com>
> ...


Hi Deepa,


Just FYI, the vger.kernel.org list server and some others
intentionally reject mails with more than 1024 characters in the
Cc header, to stop people from cross-posting to too many folks.

I realize that you merged the patch after Linus' comment about
doing things in fewer steps for the simple conversion, which is
fine, but then the patch should be obvious enough that you
don't need to Cc every single maintainer and mailing list.

I've had some cases like this, and I usually remove the people
that are less likely to reply, leaving one per subsystem.
Leaving out the cleartext names is another trick you can use
if you think that you really need to Cc more people than
allowed ;-)

	Arnd

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity 
planning reports. https://ad.doubleclick.net/ddm/clk/305295220;132659582;e
