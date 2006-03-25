From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][UPDATED PATCH 2.6.16] [Patch 9/9] Generic netlink
	interface for delay accounting
Date: Fri, 24 Mar 2006 20:19:25 -0500
Message-ID: <1143249565.5184.6.camel@jzny2>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297791.5858.31.camel@elinux04.optonline.net>
	 <1142303607.24621.63.camel@stark> <1142304506.5219.34.camel@jzny2>
	 <20060322074922.GA1164@in.ibm.com> <1143122686.5186.27.camel@jzny2>
	 <20060323154106.GA13159@in.ibm.com> <1143209061.5076.14.camel@jzny2>
	 <20060324145459.GA7495@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751070AbWCYBUE@vger.kernel.org>
To: balbir@in.ibm.com
In-Reply-To: <20060324145459.GA7495@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-24-03 at 20:24 +0530, Balbir Singh wrote:

> Hmm... Would it be ok to send one message with the following format
> 
> 1. TLV=TASKSTATS_TYPE_PID
> 2. TLV=TASKSTATS_TYPE_STATS
> 3. TLV=TASKSTATS_TYPE_TGID
> 4. TLV=TASKSTATS_TYPE_STATS
> 
> It would still be one message, except that 3 and 4 would be optional.
> What do you think?
> 

No, that wont work since #2 and #4 are basically the same TLV. [Recall
that "T" is used to index an array]. Your other alternative is to have
#4 perhaps called TASKSTATS_TGID_STATS and #2 TASKSTATS_PID_STATS
although that would smell a little.
Dont be afraid to do the nest, it will be a little painful initially but
i am sure once you figure it out you will appreciate it.

cheers,
jamal
