From: Tomas Carnecky <tom@dbservice.com>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 20:18:15 +0100
Message-ID: <41C330F7.4000806@dbservice.com>
References: <41C26DD1.7070006@trash.net> <Xine.LNX.4.44.0412170144410.12579-100000@thoron.boston.redhat.com> <41C2FF99.3020908@tmr.com> <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Davidsen <davidsen@tmr.com>,
	James Morris <jmorris@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Bryan Fulton <bryan@coverity.com>, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262120AbULQTN5@vger.kernel.org>
To: linux-os@analogic.com
In-Reply-To: <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

linux-os wrote:
> On Fri, 17 Dec 2004, Bill Davidsen wrote:
> 
>> James Morris wrote:
>>
>>> On Fri, 17 Dec 2004, Patrick McHardy wrote:
 >>>
>>> That's what I meant, you need the capability to do anything bad :-)
>>
>>
>> Are you saying that processes with capability don't make mistakes? 
>> This isn't a bug related to untrusted users doing privileged 
>> operations, it's a case of using unchecked user data.
>>
> 
> But isn't there always the possibility of "unchecked user data"?
> I can, as root, do `cp /dev/zero /dev/mem` and have the most
> spectacular crask you've evet seen. I can even make my file-
> systems unrecoverable.
> 

But the difference between you example (cp /dev/zero /dev/mem) and 
passing unchecked data to the kernel is... you _can_ check the data and 
do something about it if you discover that the data is not valid/within 
a range/whatever even if the user has full permissions.
No same person would do a 'cp /dev/zero /dev/mem', but passing bad data 
is more likely to happen, badly written userspace configuration tools etc.

tom
