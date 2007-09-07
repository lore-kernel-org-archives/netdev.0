From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Fix e100 on systems that have cache
	incoherent DMA
Date: Fri, 07 Sep 2007 14:03:31 -0700
Message-ID: <46E1BCA3.5030201@intel.com>
References: <20070831205430.7209E46C20E@localhost>
	<46E17CD7.8080605@intel.com> <46E1B75C.6090208@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Milton Miller <miltonm@bga.com>, Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: David Acker <dacker@roinet.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <46E1B75C.6090208@roinet.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David Acker wrote:
> Kok, Auke wrote:
>> first impressions are not good: pings are erratic and shoot up to 3 
>> seconds. In an overnight stress test, the receive unit went offline and 
>> never came back up (TX still working).
>>
>> it sounds like something in the logic is suspending the ru too much, but 
>> I haven't had time to look deeply into the code yet.
> 
> I don't have an e100 enabled x86 box handy but I will look into getting one setup.
> 
> I just applied this patch to my PXA255 based system http://www.compulab.co.il/x255/html/x255-cm-datasheet.htm .
> It is running 2.6.18.4 plus compulab patches plus some hostap patches plus the e100 patch.  I get:
> 
> pings going from the embedded system to a desktop machine.
> 100 packets transmitted, 100 received, 0% packet loss, time 98996ms
> rtt min/avg/max/mdev = 0.239/0.728/1.512/0.571 ms
> 
> Pings going the from the desktop machine to the embedded system
> 100 packets transmitted, 100 received, 0% packet loss, time 99217ms
> rtt min/avg/max/mdev = 0.206/0.876/1.473/0.575 ms

ok, I just got a note from our lab saying that that particular system has the 
freak ping times even without your patch applied 8)

ignoring the ping issue, we still have the ru offline, but that could have 
possibly been caused by whatever is causing this ping issue... More testing is 
needed, and I'll try to find a system without the ping issue here first.

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
