From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 5/5] r8169: ethtool hardware statistics support
Date: Wed, 9 Mar 2005 13:53:45 -0800
Message-ID: <20050309135345.5efae9b6@dxpl.pdx.osdl.net>
References: <20050309113626.6708c93e@dxpl.pdx.osdl.net>
	<200503091537.30899.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200503091537.30899.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 9 Mar 2005 15:37:30 -0600
Jon Mason <jdmason@us.ibm.com> wrote:

> Does this patch fix the problem of bogus statistics if the interface is down
I see no problem when interface is down. It returns all zero's because
the device is reset on probe (and on shutdown).
