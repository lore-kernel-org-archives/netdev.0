From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Sun, 13 Mar 2016 23:26:51 -0700
Message-ID: <20160313232651.354f6087@xeon-e3>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
	<1457525076-6923-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <phil@nwl.cc>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:63563 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752452AbcCNG0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 02:26:49 -0400
In-Reply-To: <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  9 Mar 2016 07:04:36 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> +		fprintf(f, "\t Metadata: ");
> +
> +		if (metalist[IFE_META_SKBMARK]) {
> +			len = RTA_PAYLOAD(metalist[IFE_META_SKBMARK]);
> +			if (len) {
> +				__u32 *mmark = RTA_DATA(metalist[IFE_META_SKBMARK]);
> +				fprintf(f, "use mark %d ", *mmark);
> +			} else
> +				fprintf(f, "allow mark ");

This code has diverged way from the general rule that ip utilities display
format should match the command format. For example the properties shown
on "ip route show" match those of "ip route add".

Also over the last several years, the code in iproute2 has switched from casting
RTA_DATA() everywhere to a cleaner interface rte_getattr_u32() more like what
is used in mnl library.

The code has also gotten deeply intended creating lots of lines that are too long.

WARNING: 'doesnt' may be misspelled - perhaps 'doesn't'?
#21: 
then provide a default so the user doesnt have to specify it.

WARNING: Possible unwrapped commit description (prefer a maximum 75 chars per line)
#25: 
            "Distributing Linux Traffic Control Classifier-Action Subsystem"

WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
#143: 
new file mode 100644

ERROR: "foo * bar" should be "foo *bar"
#378: FILE: tc/m_ife.c:231:
+static int print_ife(struct action_util *au, FILE * f, struct rtattr *arg)

WARNING: Missing a blank line after declarations
#384: FILE: tc/m_ife.c:237:
+	int has_optional = 0;
+	SPRINT_BUF(b1);

WARNING: Missing a blank line after declarations
#406: FILE: tc/m_ife.c:259:
+			struct tcf_t *tm = RTA_DATA(tb[TCA_IFE_TM]);
+			print_tm(f, tm);

WARNING: line over 80 characters
#449: FILE: tc/m_ife.c:302:
+				__u32 *mmark = RTA_DATA(metalist[IFE_META_SKBMARK]);

WARNING: Missing a blank line after declarations
#450: FILE: tc/m_ife.c:303:
+				__u32 *mmark = RTA_DATA(metalist[IFE_META_SKBMARK]);
+				fprintf(f, "use mark %d ", *mmark);

WARNING: line over 80 characters
#458: FILE: tc/m_ife.c:311:
+				__u32 *mhash = RTA_DATA(metalist[IFE_META_HASHID]);

WARNING: Missing a blank line after declarations
#459: FILE: tc/m_ife.c:312:
+				__u32 *mhash = RTA_DATA(metalist[IFE_META_HASHID]);
+				fprintf(f, "use hash %d ", *mhash);

WARNING: line over 80 characters
#467: FILE: tc/m_ife.c:320:
+				__u32 *mprio = RTA_DATA(metalist[IFE_META_PRIO]);

WARNING: Missing a blank line after declarations
#468: FILE: tc/m_ife.c:321:
+				__u32 *mprio = RTA_DATA(metalist[IFE_META_PRIO]);
+				fprintf(f, "use prio %d ", *mprio);

total: 1 errors, 11 warnings, 343 lines checked
