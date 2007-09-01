From: "Or Gerlitz" <or.gerlitz@gmail.com>
Subject: Re: [ofa-general] [PATCH V4 0/10] net/bonding: ADD IPoIB support for
	the bonding driver
Date: Sat, 1 Sep 2007 23:19:04 +0300
Message-ID: <15ddcffd0709011319n3d458a9cm3c97344807a72c43@mail.gmail.com>
References: <46C9B474.5020202@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org
To: rdreier@cisco.com, davem@davemloft.net, fubar@us.ibm.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <46C9B474.5020202@voltaire.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On 8/20/07, Moni Shoua <monis@voltaire.com> wrote:
> This patch series is the fourth version (see below link to V3) of the
> suggested changes to the bonding driver so it would be able to support
> non ARPHRD_ETHER netdevices for its High-Availability (active-backup) mode.
>
> The motivation is to enable the bonding driver on its HA mode to work with
> the IP over Infiniband (IPoIB) driver. With these patches I was able to enslave
> IPoIB netdevices and run TCP, UDP, IP (UDP) Multicast and ICMP traffic with
> fail-over and fail-back working fine. The working environment was the net-2.6 git.
>
> This series also includes patches to the IPoIB driver that fix some fix
> some neighboring related issues.
>
> Major changes from the previous version:
>
> 1) Addressing the issue of safety when unloading the IPoIB module before
> the bonding module
> 2) style changes
>
>
> Links to earlier discussion:
>
> 1. A discussion in netdev about bonding support for IPoIB.
> http://lists.openwall.net/netdev/2006/11/30/46
>
> 2. A discussion in openfabrics regarding changes in the IPoIB that
> enable using it as a slave for bonding.
> http://lists.openfabrics.org/pipermail/general/2007-July/038914.html

Roland, Jay, Dave

These patches hang around for about a year now where the V4 took care
of the open issues pointed during the review process. Aiming for
2.6.24, the merge window becomes close, can you provide your take
here?

thanks,

Or.
