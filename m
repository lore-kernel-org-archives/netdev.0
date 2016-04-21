From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH iproute2 v2 1/1] tc: introduce IFE action
Date: Thu, 21 Apr 2016 17:27:39 -0400
Message-ID: <571945CB.4080801@mojatatu.com>
References: <1457525076-6923-1-git-send-email-jhs@emojatatu.com>
 <1457525076-6923-2-git-send-email-jhs@emojatatu.com>
 <20160313232651.354f6087@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33736 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbcDUV1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 17:27:42 -0400
Received: by mail-io0-f173.google.com with SMTP id f89so79016613ioi.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 14:27:42 -0700 (PDT)
In-Reply-To: <20160313232651.354f6087@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry dropped the ball on this..

On 16-03-14 02:26 AM, Stephen Hemminger wrote:
> On Wed,  9 Mar 2016 07:04:36 -0500
> Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>

> This code has diverged way from the general rule that ip utilities display
> format should match the command format. For example the properties shown
> on "ip route show" match those of "ip route add".
>

Valid point (and thanks for catching this since i tend to be the biggest
whiner  on this topic ;-> I will make the changes - doesnt seem to be
far off already.
Note: in ife case it may not always symetric because there are optional
fields which may be absent in a request to the kernel but present in
a response.

> Also over the last several years, the code in iproute2 has switched from casting
> RTA_DATA() everywhere to a cleaner interface rte_getattr_u32() more like what
> is used in mnl library.
>

Will convert where it makes sense..

> The code has also gotten deeply intended creating lots of lines that are too long.
>

Is this you or the script saying the above? How is the conclusion that
we have deep indentation come about?
I checked there are some code lines that are > 80 characters because
it doesnt make sense to break them down.

> WARNING: 'doesnt' may be misspelled - perhaps 'doesn't'?
> #21:

What, checking my spelling now? ;->
I am on the internets dude!

> then provide a default so the user doesnt have to specify it.
>
> WARNING: Possible unwrapped commit description (prefer a maximum 75 chars per line)
> #25:
>              "Distributing Linux Traffic Control Classifier-Action Subsystem"
>

75 character? ;-> What happened to 80?

> WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
> #143:
> new file mode 100644
>
> ERROR: "foo * bar" should be "foo *bar"


Will fix above and rest shortly.

Also, promise to send man page later. Ive coerced someone to do it;->

cheers,
jamal
