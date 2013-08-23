From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 2/2] genl: Hold reference on correct module while netlink-dump.
Date: Fri, 23 Aug 2013 10:05:52 -0700
Message-ID: <CALnjE+o1SNmsDHACayosU8AwEekdcc-6WNdvtgSun01FTvdn6g@mail.gmail.com>
References: <1377206741-18400-1-git-send-email-pshelar@nicira.com>
	<1377242625.14021.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog122.obsmtp.com ([74.125.149.147]:49968 "HELO
	na3sys009aog122.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754482Ab3HWRFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 13:05:54 -0400
Received: by mail-qc0-f169.google.com with SMTP id m15so474155qcq.0
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 10:05:52 -0700 (PDT)
In-Reply-To: <1377242625.14021.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 23, 2013 at 12:23 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
>> +extern int __genl_register_family(struct genl_family *family, struct module *module);
>
> Why add an extra argument instead of just assigning family->module in
> the inline wrapper(s):
>
> static inline int genl_register_family(struct genl_family *family)
> {
>         family->module = THIS_MODULE;
>         return __genl_register_family(family);
> }
>
This is better, I will send updated patch.
