From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: New Defects reported by Coverity Scan for Linux
Date: Mon, 24 Apr 2017 16:41:27 -0700
Message-ID: <20170424164127.5a2145e8@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <hadi@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36578 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979193AbdDXXlf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 19:41:35 -0400
Received: by mail-pf0-f177.google.com with SMTP id 194so18585992pfv.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 16:41:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This looks like a false positive

Date: Mon, 24 Apr 2017 14:40:46 -0700
From: scan-admin@coverity.com
To: stephen@networkplumber.org
Subject: New Defects reported by Coverity Scan for Linux


1 new defect(s) introduced to Linux found with Coverity Scan.
2 defect(s), reported by Coverity Scan earlier, were marked fixed in the recent build analyzed by Coverity Scan.

New defect(s) Reported-by: Coverity Scan
Showing 1 of 1 defect(s)


** CID 1405487:  Resource leaks  (RESOURCE_LEAK)
/net/sched/act_api.c: 635 in tcf_action_init_1()


________________________________________________________________________________________________________
*** CID 1405487:  Resource leaks  (RESOURCE_LEAK)
/net/sched/act_api.c: 635 in tcf_action_init_1()
629     	 * if it exists and is only bound to in a_o->init() then
630     	 * ACT_P_CREATED is not returned (a zero is).
631     	 */
632     	if (err != ACT_P_CREATED)
633     		module_put(a_o->owner);
634     
>>>     CID 1405487:  Resource leaks  (RESOURCE_LEAK)
>>>     Variable "cookie" going out of scope leaks the storage it points to.  
635     	return a;
636     
637     err_mod:
638     	module_put(a_o->owner);
639     err_out:
640     	if (cookie) {
