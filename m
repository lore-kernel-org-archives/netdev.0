From: "Justin P. Mattock" <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Fri, 31 Dec 2010 09:59:19 -0800
Message-ID: <4D1E19F7.6000608@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<20101231064515.GC3733@angua.secretlab.ca>
	<4D1D7DAE.7060504@gmail.com> <20101231091136.GC1886@bicker>
	<4D1DE616.7010105@gmail.com> <20101231174100.GF1886@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <error27-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>,
	trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	li
Return-path: <spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20101231174100.GF1886@bicker>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=spi-devel-general>
List-Post: <mailto:spi-devel-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/spi-devel-general>,
	<mailto:spi-devel-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: spi-devel-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/31/2010 09:41 AM, Dan Carpenter wrote:
> On Fri, Dec 31, 2010 at 06:17:58AM -0800, Justin P. Mattock wrote:
>>> Wrong:  [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
>>>
>>> Right:  [PATCH 02/15] spi/dw_spi: Typo change diable to disable
>>>
>>> regards,
>>> dan carpenter
>>>
>>
>> alright.. so having the backlash is alright for the subject
>
> Well really my point is not so much about backslashes vs colons, it's
> about getting the *one* correct prefix.  This stuff is probably
> scriptable most of the time, but you may still be required to think a
> little on the corner cases.
>
> Here is a script to get you started.
>
> git log --format="%s" drivers/spi/dw_spi.c | \
> 	head -n 20 |                         \
> 	perl -ne 's/(.*):.*/$1/; print' |    \
> 	sort | uniq -c | sort -rn |          \
> 	perl -ne 's/^\W+\d+ //; print' |     \
> 	head -n 1
>
> regards,
> dan carpenter
>

thats a nice little script there(just ran it) any way you want to add 
this into to getmaintainers.pl or something? (this way people get the 
maintainers address plus a subject line in the mix)

Justin P. Mattock

------------------------------------------------------------------------------
Learn how Oracle Real Application Clusters (RAC) One Node allows customers
to consolidate database storage, standardize their database environment, and, 
should the need arise, upgrade to a full multi-node Oracle RAC database 
without downtime or disruption
http://p.sf.net/sfu/oracle-sfdevnl
