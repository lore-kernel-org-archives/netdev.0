From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 1/2] r8169: Jumbo Frames mini-increase
Date: Mon, 28 Feb 2005 14:56:24 -0600
Message-ID: <200502281456.24200.jdmason@us.ibm.com>
References: <4220ADA6.2040506@phekda.gotadsl.co.uk> <20050228193204.GA8186@electric-eye.fr.zoreil.com> <42237CDC.4060408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42237CDC.4060408@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 28 February 2005 02:19 pm, Jeff Garzik wrote:
> Random comment.
>
> I think it's terribly cute that the max packet size is 8169.  Why not
> represent that in decimal, as opposed to hexidecimal?
>
>  Jeff

It actually random that it is 8169.  Jumbo Frames MTU in r8169 is dependent on 
the rx_buf_sz.  In the 8169 case, the rx_buf_sz is actually 8191 - (ETH_HDR + 
VLAN_HDR + CRC).  Any rx_buf_sz > 8191 is split up into multiple descriptors, 
which is proving to be a bit tricky.

-- 
Jon Mason
jdmason@us.ibm.com
