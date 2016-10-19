From: Mauro Carvalho Chehab <mchehab-JsYNTwtnfakRB7SZvlqPiA@public.gmane.org>
Subject: Re: [PATCH v2 34/37] docs: fix locations of several
 documents that got moved
Date: Wed, 19 Oct 2016 11:59:18 -0200
Message-ID: <20161019115918.1162d16e@vento.lan>
References: <cover.1476801354.git.mchehab@s-opensource.com>
	<28c1f5d3867174a7017e3f3d9e9e4ebb096ceed8.1476801354.git.mchehab@s-opensource.com>
	<20161019103442.GD1461@amd>
Reply-To: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Doc Mailing List <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mauro Carvalho
 Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>, "Rafael
 J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>, Len Brown <lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jens Axboe
 <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Alessandro Zummo <a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org>, Alexandre
 Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Rob Herring
 <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, Jean Delvare
 <jdelvare-IBi9RG/b67k@public.gmane.org>, Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>, Karsten Keil
 <isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org>, Mauro Carvalho Chehab <mchehab-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Steffen
 Klassert <klassert-H0bhvm5RIPI+B2oLq8eQJv4efur1V5z/s0AfqQuZ5sE@public.gmane.org>, Greg Kroah-Hartman
 <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
 Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>, Paolo
 Bonzini <pbonzini-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Radim =?UTF-8?B?S3LEjW3DocWZ?=
 <rkrcmar-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Wim Van Sebroeck <wim@iguana.
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <rtc-linux+bncBAABBWXYTXAAKGQESCP26LQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20161019103442.GD1461@amd>
List-Post: <https://groups.google.com/group/rtc-linux/post>, <mailto:rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:rtc-linux+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/rtc-linux
List-Subscribe: <https://groups.google.com/group/rtc-linux/subscribe>, <mailto:rtc-linux+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+712029733259+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/rtc-linux/subscribe>
List-Id: netdev.vger.kernel.org

Em Wed, 19 Oct 2016 12:34:42 +0200
Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org> escreveu:

> Hi!
> 
> 
> > --- a/Documentation/ABI/testing/sysfs-kernel-slab
> > +++ b/Documentation/ABI/testing/sysfs-kernel-slab
> > @@ -347,7 +347,7 @@ Description:
> >  		because of fragmentation, SLUB will retry with the minimum order
> >  		possible depending on its characteristics.
> >  		When debug_guardpage_minorder=N (N > 0) parameter is specified
> > -		(see Documentation/kernel-parameters.txt), the minimum possible
> > +		(see Documentation/admin-guide/kernel-parameters.rst), the minimum possible
> >  		order is used and this sysfs entry can not be used to change
> >  		the order at run time.  
> 
> Dunno, but kernel-parameters.txt was already quite long... for a file
> that is referenced quite often. Adding admin-guide/ into the path does
> not really help.

The big string name starts with Documentation/ :) There are some discussions 
about changing it to doc/ (or docs/). Also, as you said, kernel-parameters
is already a big name. Perhaps we could use, instead, "kernel-parms".

If we rename kernel-parameters.rst to kernel-parms.rst, plus the doc/ rename,
then the string size will actually reduce:

-		(see Documentation/kernel-parameters.txt), the minimum possible
+		(see doc/admin-guide/kernel-parms.rst), the minimum possible

> Maybe admin-guide should go directly into Documentation/ , as that's
> what our users are interested in?

There are several problems if we keep them at Documentation/ dir:

- We'll end by mixing documents already converted to ReST with documents
  not converted yet;

- A rename is needed anyway, as Sphinx only accepts ReST files that end
  with the extension(s) defined at Documentation/conf.py (currently,
  .rst);

- A partial documentation build is made by sub-directory. If we put
  files under /Documentation, there's no way to build just one
  book.

> Plus, I'm not sure how many developers will figure out that process/
> is what describes kernel patch submission process. We have processes
> in the kernel, after all...

Do you have a better idea?

> Could we leave symlinks in place? 

My initial patch did that. It created symlinks on the
Documentation/user (with was the previous name for the admin's guide).

The big issue is how to identify what files at Documentation/ that
were not converted yet.

On this patch series, we opted to move the file and keep just a
reference to the most relevant ones, pointing to the new location:
	https://git.linuxtv.org/mchehab/experimental.git/commit/?h=lkml-books-v2&id=217462c76ee1c12b45750723059a3461018b6975
	https://git.linuxtv.org/mchehab/experimental.git/commit/?h=lkml-books-v2&id=d15595a318356804ed1bc42f509e72de9d031513

We could do something similar to Documentation/kernel-parameters.txt.
Yet, the best is, IMHO, to keep this on the absolute minimum of files,
as it also makes harder to identify what txt files still require conversion.

> People say "please follow
> CodingStyle" when reviewing patches. Saying "please follow
> process/conding-style.rst" ... somehow I don't think that's going to
> happen.

As we have a Documentation/CodingStyle (pointing to the new location),
this should still work. 

That's said, using my maintainer's hat, when I review patches from a newbie,
I actually prefer to point them to some location with the current
practices, as they usually don't know much about the Kernel's way to
receive patch. So, I reply with something like:

	"Please read this:
		https://mchehab.fedorapeople.org/kernel_docs/process/index.html
	 with instructions about how to submit your work"

For an old contributor, I just say: "please follow the coding style" 
or I reply with the output of checkpatch.pl.

Maybe it is just me, but I very much prefer to point to some URL with
everything packed altogether than to do several reviews until someone
RTFM (Read The Fine Manual), and starts to submit it right.

Thanks,
Mauro

-- 
You received this message because you are subscribed to "rtc-linux".
Membership options at http://groups.google.com/group/rtc-linux .
Please read http://groups.google.com/group/rtc-linux/web/checklist
before submitting a driver.
--- 
You received this message because you are subscribed to the Google Groups "rtc-linux" group.
To unsubscribe from this group and stop receiving emails from it, send an email to rtc-linux+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
