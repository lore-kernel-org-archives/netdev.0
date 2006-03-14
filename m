From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [Patch 9/9] Generic netlink interface for delay accounting
Date: Mon, 13 Mar 2006 18:33:27 -0800
Message-ID: <1142303607.24621.63.camel@stark>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297791.5858.31.camel@elinux04.optonline.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Jamal <hadi@cyberus.ca>, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752131AbWCNCln@vger.kernel.org>
To: Shailabh Nagar <nagar@watson.ibm.com>
In-Reply-To: <1142297791.5858.31.camel@elinux04.optonline.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-13 at 19:56 -0500, Shailabh Nagar wrote:
<snip>

> Comments addressed (all in response to Jamal)
> 
> - Eliminated TASKSTATS_CMD_LISTEN and TASKSTATS_CMD_IGNORE

The enums for these are still in the patch. See below.

<snip>

> +/*
> + * Commands sent from userspace
> + * Not versioned. New commands should only be inserted at the enum's end
> + */
> +
> +enum {
> +       TASKSTATS_CMD_UNSPEC,           /* Reserved */
> +       TASKSTATS_CMD_NONE,             /* Not a valid cmd to send
> +                                        * Marks data sent on task/tgid exit */
> +       TASKSTATS_CMD_LISTEN,           /* Start listening */
> +       TASKSTATS_CMD_IGNORE,           /* Stop listening */

>From the description I thought you had eliminated these.

> +       TASKSTATS_CMD_PID,              /* Send stats for a pid */
> +       TASKSTATS_CMD_TGID,             /* Send stats for a tgid */
> +};

Jamal, was your Mon, 13 Mar 2006 21:29:09 -0500 reply:
> Note, you are still not following the standard scheme of doing things.
> Example: using command = GET and the message carrying the TGID to note
> which TGID is of interest. Instead you have command = TGID.
> 
> cheers,
> jamal

meant to suggest that TASKSTATS_CMD_(P|TG)ID should be renamed to
TASKSTATS_CMD_GET_(P|TG)ID ? Is that sufficient? Or am I
misunderstanding?

<snip>

Cheers,
	-Matt Helsley
