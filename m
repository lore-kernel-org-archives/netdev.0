From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Kernel-janitors] Re: [PATCH 2.6.9-rc2 17/38]
 net/islpci_dev: replace schedule_timeout() with msleep()
Date: Mon, 04 Oct 2004 17:04:07 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <4161BAC7.8040305@pobox.com>
References: <5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<20040923221303.GB13244@us.ibm.com>
	<20040923221303.GB13244@us.ibm.com>
	<5.1.0.14.2.20040924074745.00b1cd40@pop.t-online.de>
	<5.1.0.14.2.20041001084419.02570b18@pop.t-online.de>
	<5.1.0.14.2.20041002105713.026705d8@pop.t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mcgrof@studorgs.rutgers.edu,
	Greg KH <greg@kroah.com>, hvr@gnu.org,
	kernel-janitors@lists.osdl.org, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Margit Schubert-While <margitsw@t-online.de>
In-Reply-To: <5.1.0.14.2.20041002105713.026705d8@pop.t-online.de>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

Margit Schubert-While wrote:
> At 09:55 01.10.2004 -0700, Greg scribeth:
> 
>> On Fri, Oct 01, 2004 at 09:04:27AM +0200, Margit Schubert-While wrote:
>> > At 00:15 01.10.2004 -0400, Jeff scribeth:
>> > >I would rather see an msleep implementation in 2.4.x...
>> >
>> > Hear, hear.
>> > And can we PLEASE have a
>> > "#define HAVE_MSLEEP"  in delay.h ?!!!
>> > (2.4. AND 2.6)
>>
>> No, this is not how the kernel source tree works, sorry.
> 
> 
> Well it happened with netdev_priv  ;-)
> (HAVE_NETDEV_PRIV)


Net driver API is intentionally more friendly to cross-version kernel 
compat than the kernel as a whole ;-)

	Jeff
