From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error,
 don't print error message, cleanup
Date: Wed, 16 May 2007 12:57:44 -0700
Message-ID: <464B6238.70102@hp.com>
References: <20070516083120.23311.3272.stgit@localhost.localdomain>	<464B2426.9060502@garzik.org>	<464B504B.5090007@hp.com>
	<464B55E1.8040501@zytor.com>	<464B5734.2070904@hp.com>
	<464B587A.70804@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>, "H. Peter Anvin" <hpa@zytor.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <464B587A.70804@garzik.org>
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

Jeff Garzik wrote:
> Rick Jones wrote:
> 
>> But that is rather incidental isn't it?  Would some sort of system 
>> health monitor be likely to be checking that for interrupt flavors?  And 
> 
> 
> Well, that's where the information is exported in a standard way.  I 
> hope you're not suggesting that a system health monitor should be 
> parsing random, driver-specific printk messages to obtain the same 
> information?

No, I wouldn't.  The only "system health monitor" I would expect to be parsing 
that sort of thing would be a human.   Perhaps I'm just backing-into the meta 
question via the specifics of this driver patch.

>> just looking at /proc/interrupts, while it tells you what sort of 
>> interrupt is being used, it doesn't (IIRC) say anything about what 
>> sort of interrupt the driver _tried_ to use.
> 
> 
> True.
> 
> In the context of this thread, it could be any number of reasons:  MSI 
> isn't compiled in.  MSI was disabled at runtime via kernel command line. 
>  MSI was disabled by BIOS quirk.  MSI enable was attempted, but failed 
> for some reason.
> 
> None of those reasons are really driver-specific, or need 
> driver-specific complaint messages.

Agreed.  But is the PCI (?) subsystem doing something in that regard or is this 
a hole?

rick jones

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
