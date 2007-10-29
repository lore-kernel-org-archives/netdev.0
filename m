From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 and ICH9 hardware
Date: Mon, 29 Oct 2007 09:19:48 -0700
Message-ID: <47260824.9070109@intel.com>
References: <4725E125.4030103@gentoo.org> <4725F212.2030103@garzik.org>
	<472603F7.8060802@juniper.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Daniel Drake <dsd@gentoo.org>,
	Jeff Garzik <jeff@garzik.org>, netdev <netdev@vger.kernel.org>
To: "David A. Ranch" <dranch@juniper.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <472603F7.8060802@juniper.net>
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

David A. Ranch wrote:
>>> e1000 is being frozen in time as "pre-PCI Express e1000's".
>>   
> Asking the question a different way, will the current e1000 driver 
> continue to get new features, performance / power / optimization tweaks, 
> etc. or is most of the primary development be moving only on the e1000e kit?

the ultimate goal is to move all the pci-express hardware support over to e1000e.

since the pci/pci-x generation e1000 chipsets do not have nearly the amount of
features that the pci-e silicon has, you can expect the e1000 driver to be
significantly stripped down.

We do however want to keep any feature that is supported for the pci/pci-x
hardware in e1000 active. we will not disable TSO for instance. As for other
features we will decide whatever makes best sense for the hardware. (e.g. none of
the 8254x chipsets support multiple queues).

All of the primary development of features will focus on e1000e.

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
