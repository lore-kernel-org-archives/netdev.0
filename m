From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH]: r8169: Expose hardware stats via ethtool
Date: Sun, 27 Feb 2005 17:59:45 -0500
Message-ID: <422250E1.6000307@pobox.com>
References: <42208D83.80803@phekda.gotadsl.co.uk> <200502261132.29261.jdmason@us.ibm.com> <4220B9C6.1010106@pobox.com> <20050226181213.GA13230@electric-eye.fr.zoreil.com> <42224F76.9000602@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jon Mason <jdmason@us.ibm.com>,
        netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <42224F76.9000602@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe wrote:
>> BUG() is a bit exagerated imho.
> 
> 
> It seems like a pretty good way of avoiding a buffer overrun to me. 
> E.g.: you copy an extra statistic in rtl8169_get_ethtool_stats(), but 
> forget to update the stats length. Is it not better to crash early, than 
> encounter random behaviour later?


Yeah, that's why the BUG() is present in 8139cp:  force an oops rather 
than continue corrupting memory, if the programmer made an error.

	Jeff
