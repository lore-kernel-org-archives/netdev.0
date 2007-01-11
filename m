From: "Or Gerlitz" <ogerlitz@voltaire.com>
Subject: Re: [RFC] [PATCH V2 0/3] bonding support for
 operation over IPoIB
Date: Thu, 11 Jan 2007 17:03:13 +0200
Message-ID: <45A651B1.9090402@voltaire.com>
References: <Pine.LNX.4.64.0611301256130.26156@zuben>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0611301256130.26156@zuben>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
 <mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

Or Gerlitz wrote:
> This patch series is a second version (see below link to V1) of the suggested
> changes to the bonding driver such that it would be able to support non ARPHRD_ETHER
> netdevices for its High-Availability (active-backup) mode.
> 
> The motivation is to enable the bonding driver on its HA mode to work with the
> IP over Infiniband (IPoIB) driver. With these patches I was able to enslave
> IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast and ICMP traffic with
> fail-over and fail-back working fine. My working env was the net-2.6.20 git.


> These patches are not enough for configuration of IPoIB bonding through tools
> (eg /sbin/ifenslave and /sbin/ifup) provided by packages such as sysconfig and
> initscripts, specifically since these tools sets the bonding device to be UP
> before enslaving anything. Once this patchset gets positive/feedback the next step
> would be to look how to enhance the tools/packages so it would be possible to
> bond/enslave with the modified code. As suggested by the bonding maintainer, this
> step can potentially involve converting ifenslave to be a script based on the bonding
> sysfs infrastructure rather on the somehow obsoleted Documentation/networking/ifenslave.c

Jay,

I would like to move forward and push the V2 patch series upstream 
through netdev and then start working on the configuration tools etc 
changes needed to support bonding IPoIB devices through non direct 
bonding sysfs scripts... are you OK with that?

If you agree to the push, who is doing this nowadays, is it Jeff Garzik 
or David Miller?

Roland - any other comments/concerns that you might have are very much 
appreciated.

Or.
