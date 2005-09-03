From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: Re: [PATCH 3/8] orinoco: Remove entry for Intel
	PRO/Wireless 2011B.
Date: Sat, 03 Sep 2005 01:02:27 -0400
Message-ID: <20050903010227.lt48u8w4kwkk000c@webmail.spamcop.net>
References: <1125619461.29016.0.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <1125619461.29016.0.camel@dv>
Content-Disposition: inline
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

Quoting Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>:

Just to preempt possible objections ...

>     Remove entry for Intel PRO/Wireless 2011B.
>
>     It is not supported by this driver because it has no firmware in
>     flash.  spectrum_cs is needed for this device.

As it turns out, there are two cards with the same ID (0x0089, 0x0001) but
different version strings.  One is Intel PRO/Wireless 2011, supported by
orinoco_cs.  The other is Intel PRO/Wireless 2011B, supported by spectrum_cs. 
So, we need a better fix.

Also, I see that many cards listed in hermes.conf from Orinoco CVS haven't made
it to the ID table in orinoco_cs.c.  I'm making a bigger table to include all
cards from Orinoco, HostAP and linux-wlan-ng.

In the meantime, the 3/8 patch could be dropped.

--
Regards,
Pavel Roskin


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
