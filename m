From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][UPDATED PATCH 2.6.16] [Patch 9/9] Generic netlink
	interface for delay accounting
Date: Fri, 24 Mar 2006 09:11:58 -0500
Message-ID: <1143209518.5076.21.camel@jzny2>
References: <1142296834.5858.3.camel@elinux04.optonline.net>
	 <1142297791.5858.31.camel@elinux04.optonline.net>
	 <1142303607.24621.63.camel@stark> <1142304506.5219.34.camel@jzny2>
	 <20060322074922.GA1164@in.ibm.com> <1143122686.5186.27.camel@jzny2>
	 <20060324013229.GD13159@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030215AbWCXONe@vger.kernel.org>
To: balbir@in.ibm.com
In-Reply-To: <20060324013229.GD13159@in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-24-03 at 07:02 +0530, Balbir Singh wrote:
> On Thu, Mar 23, 2006 at 09:04:46AM -0500, jamal wrote:

> 3. nlmsg_new() now allocates for 2*u32 + sizeof(taskstats)

Not the right size; the u32 covers the V part of TLV. The T = 16 bits
and L = 16 bits. And if you nest TLVs, then it gets more interesting.

Look at using proper macros instead of hard coding like you did.
grep for something like RTA_SPACE and perhaps send a patch to make it
generic for netlink.h

cheers,
jamal
