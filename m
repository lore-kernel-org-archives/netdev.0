From: Kumar Gala <galak@kernel.crashing.org>
Subject: converting fs_enet to net_device_ops
Date: Thu, 9 Apr 2009 09:26:08 -0500
Message-ID: <C7C29031-E717-4D83-874A-DC0D1E12BA3D@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux PPC Development <linuxppc-dev@ozlabs.org>
To: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Can someone look at converting drivers/net/fs_enet over to the new  
net_device_ops.

Dave,

Are you willing to take such a patch in for .30?  Otherwise we need to  
add a select COMPAT_NET_DEV_OPS in Kconfig for this driver (and any  
others that might not have been converted over).  drivers/net/ 
ibm_newemac/ is another.

- k
