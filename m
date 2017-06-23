From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification
 and application of configuration
Date: Fri, 23 Jun 2017 10:52:20 +0200
Message-ID: <20170623105220.18561f34@griffin>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
	<6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

This patchset looks good overall (would send my Acked-by for most of
this but I'm late).

On Mon, 19 Jun 2017 10:03:55 +0200, Matthias Schiffer wrote:
> Log messages in these
> functions are removed, as it is generally unexpected to find error output
> for netlink requests in the kernel log. Userspace should be able to handle
> errors based on the error codes returned via netlink just fine.

However, this is not really true. It's impossible to find out what went
wrong when you use e.g. iproute2 to configure a vxlan link.

We really need to convert the kernel log messages to the extended
netlink errors. Since you removed them prematurely, could you please
work on that?

Thanks,

 Jiri
