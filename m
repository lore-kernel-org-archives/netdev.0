From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 21:58:52 -0500
Message-ID: <422288EC.9010502@pobox.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <20050226181213.GA13230@electric-eye.fr.zoreil.com> <42224F76.9000602@phekda.gotadsl.co.uk> <200502272031.12291.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Dawe <rich@phekda.gotadsl.co.uk>,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200502272031.12291.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> I think I've found a (very hackish) way around the bad stats error.  
> 
> Tested on amd64, and "solves" the problem.

Seems to me, we should instead find a way to avoid calling the stats 
function if !netif_running()

	Jeff
