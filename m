From: Andi Kleen <ak@suse.de>
Subject: Re: paper
Date: Mon, 27 Jan 2003 22:19:44 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030127211944.GA16922@wotan.suse.de>
References: <20030127202145.GA3049@netppl.fi> <CDE2CBAC-323B-11D7-9775-000A956767EC@lbl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jason Lee <jrlee@lbl.gov>
Return-path: <netdev-bounce@oss.sgi.com>
To: Brian Tierney <bltierney@lbl.gov>
Content-Disposition: inline
In-Reply-To: <CDE2CBAC-323B-11D7-9775-000A956767EC@lbl.gov>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I'll check out oprofile and see what I find.

You don't even need oprofile.  Just boot the kernel with profile=2
Then before you reproduce the problem clear the profile counters
with echo > /proc/profile Afterwards read the profile data with 
/usr/sbin/readprofile

This only works for non modular code, if the problem should be in 
some modular driver it won't find it.

-Andi
