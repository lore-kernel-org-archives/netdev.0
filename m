From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/1] net: mark net_proto_ops as
	const
Date: Sat, 3 Oct 2009 04:00:06 +0400
Message-ID: <20091003000006.GA2020@x200>
References: <20091002232520.925496630@vyatta.com>
	<20091002232721.385245919@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bernard Pidoux F6BVP <f6bvp-GANU6spQydw@public.gmane.org>, Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, Henner Eisen <eis-oJ2yeFfzEm5olqkO4TVVkw@public.gmane.org>,
	Christine Caulfield <christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Ursula Braun <ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
	David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hendrik Brueckner <brueckner-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Matthias Urlichs <matthias-+qxcz+fHsVSELgA04lAiVw@public.gmane.org>,
	"Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Chas Williams <chas-vT06rRrALxcmhCb6mdbn6A@public.gmane.org>, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Mark Smith <markzzzsmith-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>,
	"Pekka Savola \(ipv6\)" <pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Huang Weiyi <weiyi.huang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	James Chapman <jchapman-Bm0nJX+W7e9BDgjK7y7TUQ@public.gmane.org>,
	Johan Hedberg <johan.hedberg-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>,
	Arnaldo Carvalho de M
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091002232721.385245919-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 02, 2009 at 04:25:21PM -0700, Stephen Hemminger wrote:
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -842,7 +842,7 @@ static struct packet_type can_packet __r
>  	.func = can_rcv,
>  };
>  
> -static struct net_proto_family can_family_ops __read_mostly = {
> +static const struct net_proto_family can_family_ops __read_mostly = {
						       ^^^^^^^^^^^^^
>  	.family = PF_CAN,
>  	.create = can_create,
>  	.owner  = THIS_MODULE,

ACK, except this chunk: const already means read-only.

------------------------------------------------------------------------------
Come build with us! The BlackBerry&reg; Developer Conference in SF, CA
is the only developer event you need to attend this year. Jumpstart your
developing skills, take BlackBerry mobile applications to market and stay 
ahead of the curve. Join us from November 9&#45;12, 2009. Register now&#33;
http://p.sf.net/sfu/devconf
