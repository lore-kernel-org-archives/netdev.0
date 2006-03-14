From: Shailabh Nagar <nagar@watson.ibm.com>
Subject: Re: [Patch 9/9] Generic netlink interface for delay accounting
Date: Mon, 13 Mar 2006 23:29:08 -0500
Message-ID: <44164694.6080206@watson.ibm.com>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
 <1142297791.5858.31.camel@elinux04.optonline.net>
 <1142303607.24621.63.camel@stark>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Jamal <hadi@cyberus.ca>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750886AbWCNE3N@vger.kernel.org>
In-reply-to: <1142303607.24621.63.camel@stark>
To: Matt Helsley <matthltc@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Helsley wrote:

>On Mon, 2006-03-13 at 19:56 -0500, Shailabh Nagar wrote:
><snip>
>
>  
>
>>Comments addressed (all in response to Jamal)
>>
>>- Eliminated TASKSTATS_CMD_LISTEN and TASKSTATS_CMD_IGNORE
>>    
>>
>
>The enums for these are still in the patch. See below.
>
><snip>
>
>  
>
>>+/*
>>+ * Commands sent from userspace
>>+ * Not versioned. New commands should only be inserted at the enum's end
>>+ */
>>+
>>+enum {
>>+       TASKSTATS_CMD_UNSPEC,           /* Reserved */
>>+       TASKSTATS_CMD_NONE,             /* Not a valid cmd to send
>>+                                        * Marks data sent on task/tgid exit */
>>+       TASKSTATS_CMD_LISTEN,           /* Start listening */
>>+       TASKSTATS_CMD_IGNORE,           /* Stop listening */
>>    
>>
>
>>From the description I thought you had eliminated these.
>  
>

Yup, typo. the commands aren't registered but the enums hang on.
Will fix.

--Shailabh
