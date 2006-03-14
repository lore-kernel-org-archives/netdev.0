From: jamal <hadi@cyberus.ca>
Subject: Re: [Patch 9/9] Generic netlink interface for delay accounting
Date: Mon, 13 Mar 2006 21:48:26 -0500
Message-ID: <1142304506.5219.34.camel@jzny2>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297791.5858.31.camel@elinux04.optonline.net>
	 <1142303607.24621.63.camel@stark>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Shailabh Nagar <nagar@watson.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932471AbWCNCsc@vger.kernel.org>
To: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <1142303607.24621.63.camel@stark>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-13-03 at 18:33 -0800, Matt Helsley wrote:
> On Mon, 2006-03-13 at 19:56 -0500, Shailabh Nagar wrote:

> Jamal, was your Mon, 13 Mar 2006 21:29:09 -0500 reply:
> > Note, you are still not following the standard scheme of doing things.
> > Example: using command = GET and the message carrying the TGID to note
> > which TGID is of interest. Instead you have command = TGID.
> > 

> meant to suggest that TASKSTATS_CMD_(P|TG)ID should be renamed to
> TASKSTATS_CMD_GET_(P|TG)ID ? Is that sufficient? Or am I
> misunderstanding?
> 

I had a long description in an earlier email feedback; but the summary
of it is the GET command is generic like TASKSTATS_CMD_GET; the message
itself carries TLVs of what needs to be gotten which are 
either PID and/or TGID etc. Anyways, theres a long spill of what i am
saying in that earlier email. Perhaps the current patch is a transition
towards that?

cheers,
jamal 
