From: Henrik Nordstrom <hno@marasystems.com>
Subject: Re: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 15:19:12 +0200 (CEST)
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <Pine.LNX.4.61.0410211510030.21167@filer.marasystems.com>
References: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
	<20041021091632.GB3551@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410211215580.19600@filer.marasystems.com>
	<20041021130837.GE3551@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041021130837.GE3551@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004, Harald Welte wrote:

> On Thu, Oct 21, 2004 at 12:25:35PM +0200, Henrik Nordstrom wrote:
>
>> The MARK bit-wise operations is also available for CONNMARK and could in
>> theory be included in CONNMARK when submitted to the kernel
>
> Yes, but doesn't the patch I just submitted to DaveM include all the
> required functionality?  both ipt_connmark and ipt_CONNMARK have a
> 'mask' parameter in ther {match,targ}info struct.

It includes the miminimal required functionality (which is already more 
than MARK), but it does not include the full bitwise operations allowing 
for xor etc, and not the same level of user friendliness in specifying the 
operation as the bitwise mark operations.

>> I am fine either way.
>
> If you think there's something (in the kernel) missing for bit-wise
> operations of CONNMARK, please let me know and send a patch.  Thanks.

The bitwise mark operations patch for CONNMARK is around somewhere.. 
looking. Found it and bounced to the netfilter-devel list separately.

Regards
Henrik
