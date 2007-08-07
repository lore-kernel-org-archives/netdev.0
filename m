From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] ibmveth: Enable TCP checksum offload
Date: Tue, 07 Aug 2007 17:46:22 -0400
Message-ID: <46B8E82E.5080107@garzik.org>
References: <11864293333377-patch-mail.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, rcjenn@linux.vnet.ibm.com,
	santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <11864293333377-patch-mail.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> This patchset enables TCP checksum offload support for IPV4
> on ibmveth. This completely eliminates the generation and checking of
> the checksum for packets that are completely virtual and never
> touch a physical network. A simple TCP_STREAM netperf run on
> a virtual network with maximum mtu set yielded a ~30% increase
> in throughput. This feature is enabled by default on systems that
> support it, but can be disabled with a module option.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>

ACK, but does not apply to current netdev-2.6.git#upstream-fixes. 
Request resend after the ibmveth fixes hit mainline (24 hours or so 
after push, I suppose)
