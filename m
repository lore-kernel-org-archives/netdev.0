From: James Ketrenos <jketreno@linux.intel.com>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel
	PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 14:18:00 -0800
Message-ID: <45CCF318.2020503@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <1171061021.7039.7.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	ipw3945-devel@lists.sourceforge.net
To: Pavel Roskin <proski@gnu.org>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1171061021.7039.7.camel@dv>
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

Pavel Roskin wrote:
> Hello, James!
> 
> On Fri, 2007-02-09 at 13:12 -0800, James Ketrenos wrote:
> 
>> You can find the new driver, and additional information about it, here:
>>
>>    http://intellinuxwireless.org/iwlwifi.
> 
> I cannot get it through git:
> 
> $ git-clone http://intellinuxwireless.org/repos/iwlwifi.git
> Initialized empty Git repository in /home/proski/src/iwlwifi/.git/
> Cannot get remote repository information.
> Perhaps git-update-server-info needs to be run there?
> 
> Perhaps git is right?  There is no info/refs there.

Updated and tested 'git clone' and its working now (I use cg-clone)

> grep: /lib/modules/2.6.20/build//include/linux/netdevice.h: No such file
> or directory
> 
> Apparently it should be looking into /lib/modules/2.6.20/source as well.
> That was a problem with the official ipw3945 drivers as well.

I'll look into it.  Does it work if you explicitly set KSRC to point to 
your kernel sources?

$ make KSRC=/lib/modules/2.6.20/source

?

Thanks,
James

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
