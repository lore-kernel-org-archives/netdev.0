From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: 2.6.32 regression, hard lock
Date: Mon, 07 Dec 2009 21:16:00 -0600
Message-ID: <4B1DC4F0.9050708@gmail.com>
References: <20091206141419.GA6195@linux-m68k.org> <20091207143057.53c6a362.akpm@linux-foundation.org> <20091208004221.GA15968@hexapodia.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Richard Zidlicky <rz@linux-m68k.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andy Isaacson <adi@hexapodia.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S935790AbZLHDQK@vger.kernel.org>
In-Reply-To: <20091208004221.GA15968@hexapodia.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/07/2009 06:42 PM, Andy Isaacson wrote:
> On Mon, Dec 07, 2009 at 02:30:57PM -0800, Andrew Morton wrote:
>> btw, why does your kernel say "To Be Filled By O.E.M." in the traces?
>> The kernel.org kernel doesn't do that.  Is that kernel patched at all?
>
> That's traditional for DMI_PRODUCT_NAME in dodgy vendor BIOSes.  I
> routinely see it on Intel evaluation boards and less frequently on
> Taiwanese Brand X boards.

It seems like the DMI board product name would be more useful than the 
system product name to print out in those messages (for kerneloops.org 
use, etc) as the system name is so frequently populated with such dummy 
values. My Asus P7P55D has the product name set to "System Product Name" 
which obviously isn't very unique or useful. Most likely only big-name 
manufactured systems would have a chance of filling that in properly.
