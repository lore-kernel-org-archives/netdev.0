From: Domen Puncer <domen@coderock.org>
Subject: Re: net/ne2k-pci: module_param conversion
Date: Wed, 24 Nov 2004 21:43:48 +0100
Message-ID: <20041124204348.GB4680@nd47.coderock.org>
References: <E1CVLFE-0002CL-PU@sputnik> <41A4E975.8070102@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: janitor@sternwelten.at, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41A4E975.8070102@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/11/04 15:05 -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >@@ -443,8 +435,7 @@ static void ne2k_pci_reset_8390(struct n
> > {
> > 	unsigned long reset_start_time = jiffies;
> > 
> >-	if (debug > 1) printk("%s: Resetting the 8390 t=%ld...",
> >-						  dev->name, jiffies);
> >+	printk(KERN_INFO "%s: Resetting the 8390 t=%ld...", dev->name, 
> >jiffies);
> 
> 
> The rest of the patch looks OK.
> 
> This chunk changes behavior, by removing the 'if' test.

This was intended.
Module parameter debug is only used in this test, so i dared removing it.
3 options:
- remove this printk
- don't remove "debug"
- leave patch as is :-)

Let me know of your decision, and i'll send a new patch.
> 
> 	Jeff
