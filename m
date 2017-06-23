From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/6] vxlan: refactor verification
 and application of configuration
Date: Fri, 23 Jun 2017 12:23:22 +0200
Message-ID: <1498213402.2595.3.camel@sipsolutions.net>
References: <cover.1497825555.git.mschiffer@universe-factory.net>
	<6e2c8bb77be42834f1da5a3ca79f5e455574a136.1497825555.git.mschiffer@universe-factory.net>
	<20170623105220.18561f34@griffin>
	<113c3fe1-f490-d92d-2b4a-69b7115d8115@universe-factory.net>
	(sfid-20170623_121415_527724_25382888)
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>, Jiri Benc
	<jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <113c3fe1-f490-d92d-2b4a-69b7115d8115-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
	(sfid-20170623_121415_527724_25382888)
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

On Fri, 2017-06-23 at 12:13 +0200, Matthias Schiffer wrote:
> 
> I was told the extended netlink error facilities were not ready yet,
> has that changed since the last release?

Yes, the facility is in the kernel tree now.

> Anyways, I will gladly work on improving the error handling if
> someone can give me a pointer how these extended netlink errors are
> used.

Just grep for 'netlink_ext_ack' :)

johannes
