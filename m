From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] use netdev_priv() in synclink (char. driver)
Date: Sat, 6 Mar 2004 20:16:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040306201640.7dd15986.rddunlap@osdl.org>
References: <20040303142907.09d0f7bd.rddunlap@osdl.org>
	<20040303150105.7ff770b0.rddunlap@osdl.org>
	<1078499709.2076.5.camel@deimos.microgate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Fulghum <paulkf@microgate.com>
In-Reply-To: <1078499709.2076.5.camel@deimos.microgate.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 05 Mar 2004 09:15:09 -0600 Paul Fulghum <paulkf@microgate.com> wrote:

| On Wed, 2004-03-03 at 17:01, Randy.Dunlap wrote:
| > | 
| > | From: Carlo Perassi <carlo@linux.it>
| > | and Randy.Dunlap <rddunlap@osdl.org>
| > 
| > 
| > Jeff, can you add this patch and the fusion/mptlan driver
| > patch as well?
| > 
| > --
| > ~Randy
| > 
| > 
| > 
[snip]
| > _
| 
| 
| This patch breaks the driver.
| 
| The pointer stored in dev->priv points to a structure that is
| allocated and maintained by the driver.
| 
| Changing from dev->priv to netdev_priv(dev) returns a pointer
| to memory at the end of the net_device structure.
| 
| These are two different things.
| 
| So with the patch, the driver gets a pointer to something
| other than the device private information that it needs.
| 
| Please dont apply this patch.

Yes, I see.

I appreciate you reviewing and catching that, Paul.

Thanks,
--
~Randy
