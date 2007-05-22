From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
 (was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Tue, 22 May 2007 10:02:53 -0700
Message-ID: <4653223D.2010108@intel.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
	<46522E6F.9060600@garzik.org>
	<20070522010137.GC8130@gondor.apana.org.au>
	<465320A6.80706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	Herbert Xu <herbert.xu@redhat.com>, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org, davej@redhat.com, stable@kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <465320A6.80706@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> Herbert Xu wrote:
>> On Mon, May 21, 2007 at 07:42:39PM -0400, Jeff Garzik wrote:
>>> applied, though as a poster (DaveJ?) noted, I'm not sure it completely 
>>> fixes the bug
>> It should fix the problem completely in 2.6.22.  For 2.6.21, we need
>> a different fix because e1000_open is directly calling e1000_up.
>>
> 
> Is there going to be a 2.6.21-stable fix for this?
> 
> Fedora is going to backport a big patchset but that won't work
> for -stable.

I've posted that before and it's up to the stable team. I think that it's a 
seriously toolarge change unless Herbert posts his short version of the fix for 
2.6.21.1. I would be OK with that.

BTW this bug is present in most recent kernels, certainly before 2.6.20...

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
