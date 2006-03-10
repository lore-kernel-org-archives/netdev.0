From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH] orinoco: fix BAP0 offset error after several days of
 operation
Date: Fri, 10 Mar 2006 18:49:48 -0500
Message-ID: <1142034588.27311.2.camel@dv>
References: <20060309184410.471bfc5e@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Jiri Benc <jbenc-AlSwsSmVLrQ@public.gmane.org>
In-Reply-To: <20060309184410.471bfc5e-IhiK2ZEFs2oCVLCxKZUutA@public.gmane.org>
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

On Thu, 2006-03-09 at 18:44 +0100, Jiri Benc wrote:
> After several days of operation of Netgear MA311 card, the card becomes
> to seek improperly and needs reset. This patch tries to reset the card
> when this situation occurs.

Thanks, applied.  I had to move the location closer to the end because
the current sources have more than one place where such failure can be
detected.

The orinoco patch series will be posted as soon as I clean them up and
split some large patches.
 
-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
