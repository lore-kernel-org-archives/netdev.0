From: Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>
Subject: Re: pull request: batman-adv 2011-07-08
Date: Fri, 8 Jul 2011 00:39:04 +0200
Message-ID: <201107080039.05143.lindner_marek@yahoo.de>
References: <1310078023-28958-1-git-send-email-lindner_marek@yahoo.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1310078023-28958-1-git-send-email-lindner_marek-LWAfsSFWpa4@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, July 08, 2011 00:33:39 Marek Lindner wrote:
> I have another small but important set of changes I'd like to get pulled
> into net-next-2.6/3.1. Despite our best efforts, recent tests and reviews
> of the protocol changes we have introduced a couple of weeks ago made it
> quite obvious that some bugs slipped through. The implementation of said
> protocol does not handle all corner cases in the way it should, thus
> provoking inconsistent states in the mesh. These 4 patches are meant to
> address the found issues.

Woops - pulled the trigger too fast. Here is the missing shortlog:

The following changes since commit 44c4349a2a117b22a5c4087f2ac9faf10c575e17:

  batman-adv: Replace version info instead of appending them (2011-07-05 14:48:56 +0200)

are available in the git repository at:
  git://git.open-mesh.org/linux-merge.git batman-adv/next

Antonio Quartulli (4):
      batman-adv: initialise last_ttvn and tt_crc for the orig_node structure
      batman-adv: keep local table consistency for further TT_RESPONSE
      batman-adv: keep global table consistency in case of roaming
      batman-adv: request the full table if tt_crc doesn't match

 net/batman-adv/originator.c        |    2 +
 net/batman-adv/packet.h            |    4 +-
 net/batman-adv/routing.c           |   12 +++
 net/batman-adv/send.c              |    4 +-
 net/batman-adv/translation-table.c |  156 +++++++++++++++++++++++++++++-------
 net/batman-adv/translation-table.h |    1 +
 6 files changed, 147 insertions(+), 32 deletions(-)
