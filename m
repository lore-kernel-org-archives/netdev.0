From: "Chei-Yol Kim" <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Subject: RE: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 15:15:44 +0900
Message-ID: <9f9701c9ed80$b7357320$8310fe81@etri.info>
Reply-To: Chei-Yol Kim <gauri-mINagvnPBMnWF1p7bDn8Kw@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        tgraf-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org
To: "Minoru Usui" <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org



>Hi, Cheiyol 
> 
>> # classid 1:10 
>> 
>> echo 0x1000A > /dev/cpuctl/foo/net_cls.classid 
>> 
>> #classid 1:20 
>> 
>> echo 0x10014 > /dev/cpuctl/bob/net_cls.classid 
> 
>(snip) 
> 
>> # add class 1:10 for foo group 
>> 
>> $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit 
>> 
>> # add class 1:20 for bob group 
>> 
>> $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit 
>> 
>> # default class 
>> 
>> $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit 

>In class ID to use TC, both a major number and a minor number are hexadecimal. 
>So 1:10 equals 0x00010010. 
> 
>I think, you should set 0x10010 to net_cls.classid if you classify to 1:10. 


I have done this by your advice. But it didn't work.
I followed the instructions by http://thread.gmane.org/gmane.linux.network/108551/focus=108661
So I supposed classid 1:10 is the decimal number, so I set the 0xA0001 as 1:10.
 
I'm curious if this patch net_cls operates well in other's hands.
How about you?
Does your system using net_cls operate well?
If then, would you let me know the environment and configuration of your system.
I would reference your environment for solving my problem.
 
Thanks again for helping
 
- Cheiyol 
