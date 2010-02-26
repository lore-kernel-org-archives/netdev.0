From: Martyn Welch <martyn.welch@ge.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Fri, 26 Feb 2010 15:18:58 +0000
Message-ID: <4B87E662.3080106@ge.com>
References: <4B6C2488.3060403@ge.com> <4B865176.7080806@ge.com> <4B86A97E.6050509@ge.com> <20100225165141.GA9686@oksana.dev.rtsoft.ru> <20100225174935.GA32370@oksana.dev.rtsoft.ru> <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com> <20100226031452.GA11319@oksana.dev.rtsoft.ru> <4B87B937.6010204@ge.com> <20100226143532.GA31622@oksana.dev.rtsoft.ru> <4B87E01E.4070704@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B87E01E.4070704@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Gortmaker wrote:
> On 10-02-26 09:35 AM, Anton Vorontsov wrote:
>   
>> On Fri, Feb 26, 2010 at 12:06:15PM +0000, Martyn Welch wrote:
>>     
>>> Anton Vorontsov wrote:
>>>       
>>>> On Thu, Feb 25, 2010 at 07:53:30PM -0500, Paul Gortmaker wrote:
>>>> [...]
>>>>
>>>>         
>>>>> I was able to reproduce it on an 8641D and bisected it down to this:
>>>>>
>>>>> -----------
>>>>> commit a3bc1f11e9b867a4f49505ecac486a33af248b2e
>>>>> Author: Anton Vorontsov<avorontsov@ru.mvista.com>
>>>>> Date:   Tue Nov 10 14:11:10 2009 +0000
>>>>>
>>>>>      gianfar: Revive SKB recycling
>>>>>
>>>>>           
>>>> Thanks for the bisect. I have a guess why tx hangs in
>>>> SMP case. Could anyone try the patch down below?
>>>>
>>>>         
>>> Yup, no problem. I'm afraid it doesn't resolve the problem for me.
>>>       
>> Hm.. I found a p2020 board and I was able to reproduce the issue.
>> The patch down below fixed it completely for me... hm.
>>     
>
> Interesting. I just tested the patch on the sbc8641d, and it
> still has the issue with your patch applied.  I'm using NFSroot
> just like Martyn was and it still appears bound up on that
> gianfar tx lock.  I'll see if I can get a SysRq backtrace in
> case that will help you see how it manages to get there...
>   

I've got a p2020ds here as well, so I'll give NFSroot on that a try with
your patch.

Martyn



-- 
Martyn Welch (Principal Software Engineer)   |   Registered in England and
GE Intelligent Platforms                     |   Wales (3828642) at 100
T +44(0)127322748                            |   Barbirolli Square, Manchester,
E martyn.welch@ge.com                        |   M2 3AB  VAT:GB 927559189
