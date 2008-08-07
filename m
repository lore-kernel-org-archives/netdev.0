From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/3] gianfar: Magic Packet and suspend/resume support.
Date: Thu, 7 Aug 2008 07:58:57 -0500
Message-ID: <E4AD279E-CA52-4F8C-BA74-15880AA29511@kernel.crashing.org>
References: <20080625215119.GB11784@loki.buserror.net>
	<489AAB3E.8020507@pobox.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset="us-ascii"; Format="flowed"; DelSp="yes"
Content-Transfer-Encoding: 7bit
Cc: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <489AAB3E.8020507@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Aug 7, 2008, at 2:58 AM, Jeff Garzik wrote:

> Scott Wood wrote:
>> Signed-off-by: Scott Wood <scottwood@freescale.com>
>> ---
>> Documentation/powerpc/booting-without-of.txt |    5 +-
>> arch/powerpc/sysdev/fsl_soc.c                |    3 +
>> drivers/net/gianfar.c                        |  118 ++++++++++++++++ 
>> +++++++++-
>> drivers/net/gianfar.h                        |   12 ++-
>> drivers/net/gianfar_ethtool.c                |   41 +++++++++-
>> include/linux/fsl_devices.h                  |    1 +
>> 6 files changed, 172 insertions(+), 8 deletions(-)
>
> did this ever get ack'd by Kumar?  I don't have a record of it.
>

A version of this is already in linus's tree.  I just forgot to add  
your Ack to it (and I apologize for that).

git commit d87eb12785c14de1586e3bad86ca2c0991300339

- k
