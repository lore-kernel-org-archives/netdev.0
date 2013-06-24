From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH iproute2 2/2] vxlan: allow specifying multiple default destinations
Date: Mon, 24 Jun 2013 08:40:48 +0300
Message-ID: <CAF1J0HNMuzFXyMprCfgv0OGcLYofnxa2tSGJq-JyEOoJbBA9OQ@mail.gmail.com>
References: <1372004643-24718-1-git-send-email-mike.rapoport@ravellosystems.com>
	<1372004643-24718-2-git-send-email-mike.rapoport@ravellosystems.com>
	<kq843h$n38$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog106.obsmtp.com ([74.125.245.80]:47077 "HELO
	na3sys010aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751289Ab3FXFkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 01:40:49 -0400
Received: by mail-ob0-f180.google.com with SMTP id eh20so10551060obb.11
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 22:40:48 -0700 (PDT)
In-Reply-To: <kq843h$n38$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 24, 2013 at 3:32 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sun, 23 Jun 2013 at 16:24 GMT, Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>> +static void explain_change(void)
>> +{
>> +     fprintf(stderr, "Usage: ... vxlan id VNI\n");
>> +     fprintf(stderr, "                 [ dstadd DST ]\n");
>> +     fprintf(stderr, "                 [ dstdel ADDR ]\n");
>> +     fprintf(stderr, "\n");
>> +     fprintf(stderr, "Where: VNI := 0-16777215\n");
>> ++    fprintf(stderr, "       DST  := [ ADDR [port PORT] [vni VNI] [via DEV]]\n");
>
> This '++' line does't look correct, does it?

Indeed so,  thanks for catching.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--
Sincerely yours,
Mike.
