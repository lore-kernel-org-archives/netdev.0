From: Andi Kleen <ak@suse.de>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Fri, 31 Oct 2003 04:16:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031031041602.0fc4f8b1.ak@suse.de>
References: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, aprasad@in.ibm.com, kaena@us.ibm.com, mfrueh@suse.de,
        olaf@suse.de, netdev@oss.sgi.com, mehul.patel@in.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mehulkumar J Patel <mehul.patel@in.ibm.com>
In-Reply-To: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2003 18:33:57 +0530
Mehulkumar J Patel <mehul.patel@in.ibm.com> wrote:

> Any update on this.
> 
> Basically we need IP CROSSOVER patch to be part of pseries kernel.

I don't think it will happen anytime soon.  But the ip_crossover patch
just create a single file which is a self contained module. You can compile
that file outside the kernel tree and load it into your running kernel.

See http://www.kernelnewbies.org etc. on how to build external modules.

-Andi
