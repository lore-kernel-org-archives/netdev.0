From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH 1/5] orinoco: Remove conditionals that are useless in
 the	kernel drivers.
Date: Fri, 16 Sep 2005 10:44:22 -0400
Message-ID: <1126881862.15991.10.camel@dv>
References: <1126851313.3056.2.camel@dv>  <432A6CD0.20108@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4uGmf/DItup6adC7n9R/"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
In-Reply-To: <432A6CD0.20108-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org


--=-4uGmf/DItup6adC7n9R/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi, Jeff!

On Fri, 2005-09-16 at 02:57 -0400, Jeff Garzik wrote:
> applied patch 1-3, and then stopped:
[skip]
> Applying 'orinoco: Add support for WE-16 and WE-17'
> 
> error: patch failed: drivers/net/wireless/orinoco.c:133
> error: drivers/net/wireless/orinoco.c: patch does not apply
> error: patch failed: drivers/net/wireless/orinoco.h:11
> error: drivers/net/wireless/orinoco.h: patch does not apply

I don't know what you are doing, but the patch applies just fine for me.
Trying to reproduce this problem, I saved the message from the mail
client (Evolution), pulled and seeked to the netdev branch
(rsync://rsync.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git) and used git-applymbox:

[proski@dv linux-2.6]$ cg-pull netdev
WARNING: The rsync access method is DEPRECATED and will be REMOVED in
the future!

receiving file list ... done
HEAD

sent 133 bytes  received 861 bytes  397.60 bytes/sec
total size is 41  speedup is 0.04

receiving file list ... done

sent 118 bytes  received 1027 bytes  763.33 bytes/sec
total size is 697  speedup is 0.61
Up to date.
[proski@dv linux-2.6]$ cg-seek netdev
On commit 065d9cac98a5406ecd5a1368f8fd38f55739dee9
[proski@dv linux-2.6]$ git-applymbox ~/commit4.mail

Applying 'orinoco: Add support for WE-16 and WE-17'

Wrote tree 9a0cb331e2d8ca6c372cfafdc8fa95211c20a6ef
Committed: a7484e843aa2a15d4a0fd15326072105539a44dc



Maybe your script doesn't like that the author of that patch is not me,
but Jean Tourrilhes?

Or maybe the patch is corrupted on your side?  Then please see the
attachment (compressed for protection).  The patches are also available
at http://red-bean.com/proski/orinoco/

-- 
Regards,
Pavel Roskin

--=-4uGmf/DItup6adC7n9R/
Content-Disposition: attachment; filename=commit4.diff.gz
Content-Type: application/x-gzip; name=commit4.diff.gz
Content-Transfer-Encoding: base64

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


--=-4uGmf/DItup6adC7n9R/--



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
