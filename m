From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Tue, 21 Sep 2004 10:58:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921085809.GD8058@wotan.suse.de>
References: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20040920225140.GH1307@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> 6) Since everybody agrees the current scheme of bucket-sizing based on
>    memory only is a bad idea, do we want to unify this bucket sizing
>    code, so people have one single knob (boot option) which they can use
>    to give the system some metrics on how large it should scale all the
>    network hash tables?

I think this is the right way to go. In fact I would go one step
farther and add a single knob for all hash tables.
This requires to put all the cut'n'pasted hash table setup
code into a single utility function that does this.

-Andi
