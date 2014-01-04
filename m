From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] fixup! add support for IFA_F_MANAGETEMPADDR
Date: Sat, 4 Jan 2014 11:44:13 +0100
Message-ID: <20140104104413.GC9295@minipsycho.orion>
References: <1388676879-2603-3-git-send-email-jiri@resnulli.us>
 <1388677815-5815-1-git-send-email-thaller@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Thomas Haller <thaller@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:63133 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbaADKoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 05:44:16 -0500
Received: by mail-ee0-f41.google.com with SMTP id t10so7126168eei.14
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 02:44:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1388677815-5815-1-git-send-email-thaller@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 02, 2014 at 04:50:15PM CET, thaller@redhat.com wrote:
>Signed-off-by: Thomas Haller <thaller@redhat.com>
>---
> I think, also the following changes are needed(??)

Right. I will incorporate this into the patch and send v3. Thanks Thomas	

>
> ip/ipaddress.c | 5 ++++-
> 1 file changed, 4 insertions(+), 1 deletion(-)
>
>diff --git a/ip/ipaddress.c b/ip/ipaddress.c
>index 5dbb017..b0d54fe 100644
>--- a/ip/ipaddress.c
>+++ b/ip/ipaddress.c
>@@ -82,7 +82,7 @@ static void usage(void)
> 	fprintf(stderr, "           tentative | deprecated | dadfailed | temporary |\n");
> 	fprintf(stderr, "           CONFFLAG-LIST ]\n");
> 	fprintf(stderr, "CONFFLAG-LIST := [ CONFFLAG-LIST ] CONFFLAG\n");
>-	fprintf(stderr, "CONFFLAG  := [ home | nodad ]\n");
>+	fprintf(stderr, "CONFFLAG  := [ home | nodad | mngtmpaddr ]\n");
> 	fprintf(stderr, "LIFETIME := [ valid_lft LFT ] [ preferred_lft LFT ]\n");
> 	fprintf(stderr, "LFT := forever | SECONDS\n");
> 
>@@ -1130,6 +1130,9 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
> 		} else if (strcmp(*argv, "nodad") == 0) {
> 			filter.flags |= IFA_F_NODAD;
> 			filter.flagmask |= IFA_F_NODAD;
>+		} else if (strcmp(*argv, "mngtmpaddr") == 0) {
>+			filter.flags |= IFA_F_MANAGETEMPADDR;
>+			filter.flagmask |= IFA_F_MANAGETEMPADDR;
> 		} else if (strcmp(*argv, "dadfailed") == 0) {
> 			filter.flags |= IFA_F_DADFAILED;
> 			filter.flagmask |= IFA_F_DADFAILED;
>-- 
>1.8.4.2
>
