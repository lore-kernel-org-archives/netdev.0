From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Use pr_cont where appropriate
Date: Mon, 6 Mar 2017 18:02:05 +0100
Message-ID: <20170306170204.GA5643@salvia>
References: <82a5ec63e547c425644d2dd0165fcc664a2b265e.1488319732.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <82a5ec63e547c425644d2dd0165fcc664a2b265e.1488319732.git.joe@perches.com>
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

On Tue, Feb 28, 2017 at 02:09:24PM -0800, Joe Perches wrote:
> Logging output was changed when simple printks without KERN_CONT
> are now emitted on a new line and KERN_CONT is required to continue
> lines so use pr_cont.
> 
> Miscellanea:
> 
> o realign arguments
> o use print_hex_dump instead of a local variant

Applied, thanks Joe.
