From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2.6.12-rc1-mm1] net/ethernet/eth.c - eth_header
Date: Wed, 23 Mar 2005 14:52:15 -0600
Message-ID: <200503231452.15835.jdmason@us.ibm.com>
References: <200503231734.59277.vicente.feito@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Vicente Feito <vicente.feito@gmail.com>
In-Reply-To: <200503231734.59277.vicente.feito@gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 23 March 2005 11:34 am, Vicente Feito wrote:
> Hi,
> Please consider applying (or droping).
> Thank you.
>
> Description: This patch prevent drivers from calling eth_header with a
> 802.3 frame using a len>1536. In such a case returns -EINVAL, which was
> hard to choose because the ETH_HLEN is supposed to return.

Won't this break jumbo frames?

-- 
Jon Mason
jdmason@us.ibm.com
