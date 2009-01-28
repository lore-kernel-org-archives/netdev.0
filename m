From: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Subject: Re: [BUG] tg3 module problem on Linux-2.6.29-rc1-2
Date: Wed, 28 Jan 2009 17:10:50 +0200
Message-ID: <4980757A.1010900@turknet.net.tr>
References: <49771D65.3090205@turknet.net.tr> <20090121152818.GA3438@x200.localdomain> <497870A3.4070200@turknet.net.tr> <3f9a31f40901262230s3efb9242jcd4a02ee84944daa@mail.gmail.com> <497EBBB1.5020609@turknet.net.tr> <497F2CDC.6050106@turknet.net.tr> <20090127183533.GA10466@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netone.net.tr ([193.192.98.182]:28039 "EHLO
	mail.turknet.net.tr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbZA1PKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 10:10:53 -0500
In-Reply-To: <20090127183533.GA10466@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:
> On Tue, Jan 27, 2009 at 07:48:44AM -0800, Tarkan Erimer wrote:
>   
>> Tarkan Erimer wrote:
>>     
>>> Jaswinder Singh Rajput wrote:
>>>       
>>>> Is this ubuntu's specific problem or you also getting these
>>>> warnings/errors on another releases.
>>>>
>>>>   
>>>>         
>>> Yes,it's specific to Ubuntu's kernel build process (make-kpkg). I had 
>>> no time to try with regular kernel build process. But; if it's 
>>> necessary, I can try it out. BTW, my box is Kubuntu 8.10 with latest 
>>> updates.
>>>
>>>       
>> Now, I tried with 2.6.29-rc2-git2 and the result is same. No difference. 
>> When I have time, I'll try via regular kernel compile process to see 
>> what will be happen.
>>     
>
> Like I outlined in my previous email, this is a scripting / tools problem.
> Updating your kernel will not help.  Either the script or modinfo needs to
> be modified to somehow recognize that while the driver does make
> request_firmware() calls, the firmware resides in the kernel itself.
>
>   
I got it. Sorry for the noise.


