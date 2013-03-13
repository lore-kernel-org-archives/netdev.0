From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH] net/ieee802154/6lowpan: Fix
 initialization for fragment offset
Date: Wed, 13 Mar 2013 11:45:42 -0400
Message-ID: <51409F26.6070100@signal11.us>
References: <1363161054-13471-1-git-send-email-poettner@ibr.cs.tu-bs.de>
	<20130313.103830.247889330240632952.davem@davemloft.net>
	<D859EF9A-19A9-4F74-B59D-28FADBCE338A@ibr.cs.tu-bs.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1287764834906770095=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <D859EF9A-19A9-4F74-B59D-28FADBCE338A-G+tS6SCNB47quOJu9mQKZg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1287764834906770095==
Content-Type: multipart/alternative;
	boundary="------------000208030905020704050700"

This is a multi-part message in MIME format.
--------------000208030905020704050700
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/13/2013 10:40 AM, Wolf-Bastian P=F6ttner wrote:
> Nope. The patch fixes a problem in code that is not in mainline yet. Ho=
wever, people on the linux-zigbee mailing list found it a good idea to co=
mmit this change to mainline to avoid the problem from arising.
>
> I see, you disagree. Nevermind. ;)

Hi David,

This is my fault. I must have been looking the wrong tree when I
recommended a push to mainline.

Sorry for the noise.

Alan.

> Am 13.03.2013 um 15:38 schrieb David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>:
>> > From: Wolf-Bastian P=F6ttner <poettner-G+tS6SCNB47quOJu9mQKZg@public.gmane.org>
>> > Date: Wed, 13 Mar 2013 08:50:54 +0100
>> >=20
>>> >> offset has to be initialized, otherwise the *first* fragment will
>>> >> be discarded and reassembly cannot happen.
>>> >>=20
>>> >> Reviewed-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
>> >=20
>> > 'offset' is never used unless lowpan_fetch_skb_u8(skb, &offset)
>> > succeeds, in which case it will be initialized properly.  Otherwise =
we
>> > unlock and drop the SKB and make no references whatsoever to 'offset=
'.
>> >=20
>> > I suspect you saw some compiler warning about 'offset' being
>> > uninitialized, and are just blindly trying to shut this warning up.
>


--------------000208030905020704050700
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body bgcolor="#FFFFFF" text="#000000">
    <div class="moz-cite-prefix">On 03/13/2013 10:40 AM, Wolf-Bastian
      P&ouml;ttner wrote:<br>
    </div>
    <blockquote
      cite="mid:D859EF9A-19A9-4F74-B59D-28FADBCE338A-G+tS6SCNB47quOJu9mQKZg@public.gmane.org"
      type="cite">
      <div class="moz-text-plain" wrap="true" graphical-quote="true"
        style="font-family: -moz-fixed; font-size: 12px;"
        lang="x-western">
        <pre wrap="">Nope. The patch fixes a problem in code that is not in mainline yet. However, people on the linux-zigbee mailing list found it a good idea to commit this change to mainline to avoid the problem from arising.

I see, you disagree. Nevermind. <span class="moz-smiley-s3" title=";)"><span>;)</span></span></pre>
      </div>
    </blockquote>
    <br>
    Hi David,<br>
    <br>
    This is my fault. I must have been looking the wrong tree when I
    recommended a push to mainline. <br>
    <br>
    Sorry for the noise.<br>
    <br>
    Alan.<br>
    <br>
    <blockquote
      cite="mid:D859EF9A-19A9-4F74-B59D-28FADBCE338A-G+tS6SCNB47quOJu9mQKZg@public.gmane.org"
      type="cite">
      <div class="moz-text-plain" wrap="true" graphical-quote="true"
        style="font-family: -moz-fixed; font-size: 12px;"
        lang="x-western">
        <pre wrap=""><div class="moz-txt-sig">Am 13.03.2013 um 15:38 schrieb David Miller <a moz-do-not-send="true" class="moz-txt-link-rfc2396E" href="mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org">&lt;davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org&gt;</a>:

</div></pre>
        <blockquote type="cite" style="color: #000000;">
          <pre wrap=""><span class="moz-txt-citetags">&gt; </span>From: Wolf-Bastian P&ouml;ttner <a moz-do-not-send="true" class="moz-txt-link-rfc2396E" href="mailto:poettner-G+tS6SCNB47quOJu9mQKZg@public.gmane.org">&lt;poettner-G+tS6SCNB47quOJu9mQKZg@public.gmane.org&gt;</a>
<span class="moz-txt-citetags">&gt; </span>Date: Wed, 13 Mar 2013 08:50:54 +0100
<span class="moz-txt-citetags">&gt; </span>
</pre>
          <blockquote type="cite" style="color: #000000;">
            <pre wrap=""><span class="moz-txt-citetags">&gt;&gt; </span>offset has to be initialized, otherwise the <b class="moz-txt-star"><span class="moz-txt-tag">*</span>first<span class="moz-txt-tag">*</span></b> fragment will
<span class="moz-txt-citetags">&gt;&gt; </span>be discarded and reassembly cannot happen.
<span class="moz-txt-citetags">&gt;&gt; </span>
<span class="moz-txt-citetags">&gt;&gt; </span>Reviewed-by: Alan Ott <a moz-do-not-send="true" class="moz-txt-link-rfc2396E" href="mailto:alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org">&lt;alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org&gt;</a>
</pre>
          </blockquote>
          <pre wrap=""><span class="moz-txt-citetags">&gt; </span>
<span class="moz-txt-citetags">&gt; </span>'offset' is never used unless lowpan_fetch_skb_u8(skb, &amp;offset)
<span class="moz-txt-citetags">&gt; </span>succeeds, in which case it will be initialized properly.  Otherwise we
<span class="moz-txt-citetags">&gt; </span>unlock and drop the SKB and make no references whatsoever to 'offset'.
<span class="moz-txt-citetags">&gt; </span>
<span class="moz-txt-citetags">&gt; </span>I suspect you saw some compiler warning about 'offset' being
<span class="moz-txt-citetags">&gt; </span>uninitialized, and are just blindly trying to shut this warning up.
</pre>
        </blockquote>
        <br>
      </div>
    </blockquote>
    <br>
  </body>
</html>

--------------000208030905020704050700--


--===============1287764834906770095==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
--===============1287764834906770095==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linux-zigbee-devel mailing list
Linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel

--===============1287764834906770095==--
