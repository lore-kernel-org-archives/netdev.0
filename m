From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Tue, 14 Aug 2012 23:23:51 -0400
Message-ID: <502B1647.3070802@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jan Ariyasu <jan.ariyasu@hp.com>
To: Jan Ariyasu <jan.ariyasu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/04/2012 05:30 PM, Jan Ariyasu wrote:
> The following set of patches enable network-namespaces for the SCTP protocol.
>
> The multitude of global parameters are stored in a net_generic
> structure, and the bulk of the patches enable the protocol to access
> the parameters on a per-namespace basis.  The first five patches
> enable netns handling of the protocol, procfs and sysfs.
>
> Signed-off-by: Jan Ariyasu <jan.ariyasu@hp.com>
> ---
>

NACK.  Sorry Jan, but Eric's patches are much cleaner and do everything 
that's needed.

-vlad
