From: Pavel Roskin <proski@gnu.org>
Subject: Re: iwlwifi initial bugs/thanks
Date: Tue, 13 Feb 2007 15:18:36 -0500
Message-ID: <1171397916.2414.31.camel@dv>
References: <1171382436.12035.38.camel@localhost>
	<20070213191313.GA2427@metaxa.reflex>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ipw3945-devel@lists.sourceforge.net
To: Jason Lunz <lunz@falooley.org>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070213191313.GA2427@metaxa.reflex>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-13 at 14:13 -0500, Jason Lunz wrote:
> The "_rename" suffix is an indication that you have udev rules that are
> attempting to assign the same name to two different netdevs. Try to
> disable udev device renaming, or make the rules more specific.
> 
> The attached kernel patch makes it easier to figure out what udev is
> trying to do in situations like yours. It keeps getting rejected from
> linux upstream, but that could change with enough encouragement.

I think it's a good idea.  Many drivers use the device name in the
diagnostic messages.  What's the point in seeing "wlan0: buffer
overflow" if there is no way to find out from the log what that "wlan0"
used to be?

> +		if (strncmp(newname, dev->name, IFNAMSIZ))
> +			printk(KERN_INFO "%s renamed to %s\n", dev->name, newname);

I think KERN_INFO is the right level, but maybe KERN_DEBUG would be more
readily accepted.

-- 
Regards,
Pavel Roskin


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
