From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: ebtables: use audit_log()
Date: Sat, 19 Aug 2017 13:25:10 +0200
Message-ID: <20170819112510.GA4761@salvia>
References: <5f901760510d0dc6e6e971d4136c8d2d4e0a13fd.1502103408.git.geliangtang@gmail.com>
	<bcbd9b076cee1b585a756a1eadd16325dc341ca4.1502098910.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Florian Westphal <fw@strlen.de>, linux-kernel@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>
To: Geliang Tang <geliangtang@gmail.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <bcbd9b076cee1b585a756a1eadd16325dc341ca4.1502098910.git.geliangtang@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 07, 2017 at 09:44:25PM +0800, Geliang Tang wrote:
> Use audit_log() instead of open-coding it.

Applied, thanks.

BTW, I have collapse your xtables change to this patch too.  part of
the same logical change. Hint: If you see yourself writing exactly the
same description for each patch you submit then it's likely to be fine
to merge them into one single patch. Just for the next time.
